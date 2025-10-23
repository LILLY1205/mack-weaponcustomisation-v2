local RSGCore = exports['rsg-core']:GetCoreObject()

local function jenc(v)
  local ok, res = pcall(json.encode, v or {})
  return ok and res or '{}'
end

local function jdec(v)
  local ok, res = pcall(json.decode, v or '{}')
  return ok and res or {}
end

-- Bulletpress state
local PropsLoaded = false

-- Provide schema to clients
lib.callback.register('mack-weaponcustomisation:getSchema', function(source, weaponNameOrHash)
    local schema = Config.Schema or {}
    local defaults = schema.defaults or {}
    local per = schema.perWeapon or {}
    local chosen = defaults
    if weaponNameOrHash and per[weaponNameOrHash] then
        chosen = per[weaponNameOrHash]
    end
    return { ok = true, schema = chosen }
end)

-- Fetch weapon components for a player's serial
lib.callback.register('mack-weaponcustomisation:getComponents', function(source, serial)
    local src = source
    if not serial or serial == '' then return { ok = false, error = 'missing_serial' } end

    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return { ok = false, error = 'no_player' } end

    local citizenid = Player.PlayerData.citizenid
    local rows = MySQL.query.await(('SELECT id, components, components_before FROM %s WHERE serial = ? AND citizenid = ? LIMIT 1'):format(Config.Table), { serial, citizenid })

    if rows and rows[1] then
        return {
            ok = true,
            id = rows[1].id,
            components = jdec(rows[1].components),
            components_before = jdec(rows[1].components_before),
        }
    else
        return { ok = true, id = nil, components = {}, components_before = {} }
    end
end)

local function computePrice(components)
    local price = 0.0
    if type(components) ~= 'table' then return price end
    local p = Config.Price or Config.price or {}
    for cat, idx in pairs(components) do
        local n = tonumber(idx or -1)
        if n and n >= 0 then
            price = price + (p[cat] or 0.0)
        end
    end
    return price
end

local function upsertComponents(src, serial, newComponents)
    if type(newComponents) ~= 'table' then newComponents = {} end
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return false end
    local citizenid = Player.PlayerData.citizenid

    local rows = MySQL.query.await(('SELECT id, components FROM %s WHERE serial = ? AND citizenid = ? LIMIT 1'):format(Config.Table), { serial, citizenid })
    local prev = (rows and rows[1] and rows[1].components) or '{}'

    if rows and rows[1] then
        MySQL.update.await(([[UPDATE %s SET components_before = ?, components = ? WHERE id = ?]]):format(Config.Table), {
            prev,
            jenc(newComponents),
            rows[1].id
        })
    else
        MySQL.insert.await(([[INSERT INTO %s (serial, citizenid, components, components_before) VALUES (?, ?, ?, ?)]]):format(Config.Table), {
            serial,
            citizenid,
            jenc(newComponents),
            prev
        })
    end
    return true
end

-- Save components for a player's serial; stores previous in components_before
RegisterNetEvent('mack-weaponcustomisation:saveComponents', function(serial, newComponents)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    if upsertComponents(src, serial, newComponents) then
        Config.Notify('Weapon Customisation', 'Saved components for serial ' .. tostring(serial), 'success')
    end
end)

-- Pay & Save: either charge money or consume materials and then save
RegisterNetEvent('mack-weaponcustomisation:payAndSave', function(serial, newComponents)
  local src = source
  local Player = RSGCore.Functions.GetPlayer(src)
  if not Player then return end
  if not serial or serial == '' then
    TriggerClientEvent('mack-weaponcustomisation:paid', src, false, 0.0, 'missing_serial')
    return
  end

  if Config.UseMaterialsForCustomise then
    -- Compute materials required from Config.CustomMaterials
    local mats = {}
    local def = (Config.CustomMaterials and Config.CustomMaterials.default) or {}
    local perW = (Config.CustomMaterials and Config.CustomMaterials.perWeapon) or {}
    -- Get current weapon name not strictly required; using global defaults
    for cat, idx in pairs(newComponents or {}) do
      local nidx = tonumber(idx or -1)
      if nidx and nidx >= 0 then
        local lst = def[cat] or {}
        for _, it in ipairs(lst) do
          if it and it.item and it.amount then
            mats[it.item] = (mats[it.item] or 0) + tonumber(it.amount or 0)
          end
        end
      end
    end
    -- Check and remove
    for item, need in pairs(mats) do
      local itm = Player.Functions.GetItemByName and Player.Functions.GetItemByName(item)
      if not itm or (itm.amount or 0) < need then
        TriggerClientEvent('mack-weaponcustomisation:paid', src, false, 0.0, ('missing_%s'):format(item))
        return
      end
    end
    for item, need in pairs(mats) do
      Player.Functions.RemoveItem(item, need)
      TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove')
    end

    if upsertComponents(src, serial, newComponents) then
      TriggerClientEvent('mack-weaponcustomisation:paid', src, true, 0.0, nil)
      Config.Notify('Weapon Customisation', 'Materials used. Customisation saved.', 'success')
    else
      TriggerClientEvent('mack-weaponcustomisation:paid', src, false, 0.0, 'save_failed')
    end
    return
  end

  -- Money path (legacy)
  local price = computePrice(newComponents)
  local account = Config.PayAccount or 'cash'
  local balance = 0
  if Player.Functions.GetMoney then
    balance = tonumber(Player.Functions.GetMoney(account) or 0) or 0
  end
  if balance < price then
    TriggerClientEvent('mack-weaponcustomisation:paid', src, false, price, 'insufficient_funds')
    return
  end
  local ok = false
  if Player.Functions.RemoveMoney then
    ok = Player.Functions.RemoveMoney(account, price, 'weapon-customisation') and true or false
  end
  if not ok then
    TriggerClientEvent('mack-weaponcustomisation:paid', src, false, price, 'payment_failed')
    return
  end
  if upsertComponents(src, serial, newComponents) then
    TriggerClientEvent('mack-weaponcustomisation:paid', src, true, price, nil)
    Config.Notify('Weapon Customisation', ('Charged $%0.2f and saved for serial %s'):format(price, tostring(serial)), 'success')
  else
    TriggerClientEvent('mack-weaponcustomisation:paid', src, false, price, 'save_failed')
  end
end)

-- Simple admin command to check a serial
lib.addCommand('mackwc_check', {
  help = 'Check saved weapon components for a serial',
  params = {
    { name = 'serial', help = 'Weapon serial', type = 'string' }
  }
}, function(source, args)
  local src = source
  local serial = args.serial
  if src <= 0 then print('Use in-game') return end
  local reply = lib.callback.await('mack-weaponcustomisation:getComponents', src, serial)
  if reply and reply.ok then
    Config.Notify('Weapon Customisation', ('Serial %s: found=%s'):format(serial, reply.id and 'yes' or 'no'), 'inform')
    print(('[mack-weaponcustomisation] components: %s'):format(jenc(reply.components)))
    print(('[mack-weaponcustomisation] components_before: %s'):format(jenc(reply.components_before)))
  else
    Config.Notify('Weapon Customisation', 'Lookup failed: ' .. (reply and (reply.error or 'unknown') or 'nil'), 'error')
  end
end)

-- ===== Bulletpress integration (server side) =====

-- Useable item to place a new bulletpress (workbench)
RSGCore.Functions.CreateUseableItem('gunsmithgench', function(source)
  local src = source
  local Player = RSGCore.Functions.GetPlayer(src)
  if not Player then return end
  TriggerClientEvent('mm-bulletpress:client:createstash', src, 'playerstash', Config.StashProp)
  if Player.Functions.RemoveItem then
    Player.Functions.RemoveItem('gunsmithgench', 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['gunsmithgench'], 'remove')
  end
end)


RSGCore.Functions.CreateCallback('mm-bulletpress:server:checkingredients', function(source, cb, ingredients)
  local src = source
  local Player = RSGCore.Functions.GetPlayer(src)
  if not Player then cb(false) return end
  for _, ing in pairs(ingredients or {}) do
    local itm = Player.Functions.GetItemByName and Player.Functions.GetItemByName(ing.item)
    if not itm or (itm.amount or 0) < (ing.amount or 0) then
      cb(false)
      return
    end
  end
  cb(true)
end)

RegisterServerEvent('mm-bulletpress:server:finishcrafting')
AddEventHandler('mm-bulletpress:server:finishcrafting', function(ingredients, receive)
  local src = source
  local Player = RSGCore.Functions.GetPlayer(src)
  if not Player then return end
  for _, ing in pairs(ingredients or {}) do
    Player.Functions.RemoveItem(ing.item, ing.amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[ing.item], 'remove')
  end
  Player.Functions.AddItem(receive, 1)
  TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], 'add')
  TriggerClientEvent('RSGCore:Notify', src, 'crafting finished!', 'success')
end)

RegisterNetEvent('RSGCore:Server:PlayerLoaded', function(Player)
  local src = Player.PlayerData.source
  -- Send current known props to this player when they join
  TriggerClientEvent('mm-bulletpress:client:updatePropData', src, Config.PlayerProps)
end)

RegisterNetEvent('mm-bulletpress:server:requestProps')
AddEventHandler('mm-bulletpress:server:requestProps', function()
  local src = source
  TriggerClientEvent('mm-bulletpress:client:updatePropData', src, Config.PlayerProps)
end)



RegisterServerEvent('mm-bulletpress:server:newProp')
AddEventHandler('mm-bulletpress:server:newProp', function(proptype, location, heading, hash)
  local src = source
  local Player = RSGCore.Functions.GetPlayer(src)
  if not Player then return end
  local propId = math.random(111111, 999999)
  local citizenid = Player.PlayerData.citizenid
  local PropData = {
    id = propId, proptype = proptype, x = location.x, y = location.y, z = location.z, h = heading, hash = hash, builder = citizenid, buildttime = os.time()
  }
  table.insert(Config.PlayerProps, PropData)
MySQL.insert.await('INSERT INTO mack_gunsmith (properties, propid, citizenid, proptype) VALUES (?, ?, ?, ?)', { jenc(PropData), propId, citizenid, proptype })
  TriggerClientEvent('mm-bulletpress:client:updatePropData', -1, Config.PlayerProps)
end)

RegisterServerEvent('mm-bulletpress:server:destroyProp')
AddEventHandler('mm-bulletpress:server:destroyProp', function(stashId)
  local src = source
  local Player = RSGCore.Functions.GetPlayer(src)
  if not Player then return end
  local cid = Player.PlayerData.citizenid
local ownerCid = MySQL.scalar.await('SELECT citizenid FROM mack_gunsmith WHERE propid = ?', { stashId })
  if ownerCid and ownerCid == cid then
    TriggerClientEvent('mm-bulletpress:client:removePropObject', -1, stashId)
MySQL.update.await('DELETE FROM mack_gunsmith WHERE propid = ?', { stashId })
    for k, v in ipairs(Config.PlayerProps) do if v.id == stashId then table.remove(Config.PlayerProps, k) break end end
  end
end)

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end
  -- Load persisted props
local result = MySQL.query.await('SELECT properties FROM mack_gunsmith')
  for _, row in ipairs(result or {}) do
    if row.properties then
      local propData = jdec(row.properties)
      if propData and propData.id then
        local exists=false; for _, p in ipairs(Config.PlayerProps) do if p.id==propData.id then exists=true break end end
        if not exists then table.insert(Config.PlayerProps, propData) end
      end
    end
  end
  TriggerClientEvent('mm-bulletpress:client:updatePropData', -1, Config.PlayerProps)
end)
