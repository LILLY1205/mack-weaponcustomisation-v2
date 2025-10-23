local RSGCore = exports['rsg-core']:GetCoreObject()

-- NUI-driven flow with a simple grid. Player chooses components; we save to DB.

local function debugPrint(...)
    if Config.Debug then print('[mack-weaponcustomisation]', ...) end
end

local function notify(title, description, type)
    Config.Notify(title, description, type)
end

local function parseJson(txt)
    if type(txt) ~= 'string' or txt == '' then return {} end
    local ok, data = pcall(json.decode, txt)
    return ok and data or {}
end

local currentSerial = nil
local currentSerialCache = nil
local uiOpen = false

-- Accept serial pushed from weapon systems
RegisterNetEvent('rsg-weapons:client:currentSerial', function(serial)
    currentSerialCache = serial
    if Config.Debug then print('[mack-weaponcustomisation] cache serial (rsg-weapons):', serial) end
end)
RegisterNetEvent('rsg-weaponcomp:client:currentSerial', function(serial)
    currentSerialCache = serial
    if Config.Debug then print('[mack-weaponcustomisation] cache serial (rsg-weaponcomp):', serial) end
end)
RegisterNetEvent('mack-weaponcustomisation:client:updateSerial', function(serial)
    currentSerialCache = serial
    if Config.Debug then print('[mack-weaponcustomisation] cache serial (direct):', serial) end
end)

local function getByPath(tbl, path)
    if type(tbl) ~= 'table' or not path or path == '' then return nil end
    local cur = tbl
    for seg in string.gmatch(path, "[^%.]+") do
        if type(cur) ~= 'table' then return nil end
        cur = cur[seg]
        if cur == nil then return nil end
    end
    return cur
end

local function tryAutoDetectSerial()
    if Config.Debug then print('[mack-weaponcustomisation] Detecting serial...') end

    -- Prefer cached serial pushed by weapon scripts
    if currentSerialCache and currentSerialCache ~= '' then
        if Config.Debug then print('[mack-weaponcustomisation] using cached serial:', currentSerialCache) end
        return currentSerialCache
    end

    -- Try several likely resource names and rely on export availability rather than resource state
    local names = { 'rsg-weapons', 'rsg_weapons', 'rsgweapons', 'RSG-Weapons' }
    if Config.RSGWeaponsResourceName and Config.RSGWeaponsResourceName ~= '' then
        table.insert(names, 1, Config.RSGWeaponsResourceName)
    end
    local tried = {}
    for _, res in ipairs(names) do
        tried[#tried+1] = res
        local tries = 0
        while tries < 5 do -- fast (<=0.5s) check total
            local ok, out = pcall(function()
                local ped = PlayerPedId()
                local wHash = GetPedCurrentHeldWeapon(ped)
                if Config.Debug then print('[mack-weaponcustomisation] current wHash:', wHash, ' using resource:', res, 'try', tries) end
                if wHash and wHash ~= GetHashKey('WEAPON_UNARMED') then
                    local map = nil
                    local okexp, result = pcall(function()
                        if exports[res] and exports[res].weaponInHands then return exports[res]:weaponInHands() end
                        -- Some resources expose with different syntax; try no-colon call
                        if exports[res] and exports[res].weaponInHands then return exports[res].weaponInHands() end
                        return nil
                    end)
                    if okexp then map = result end
                    if type(map) == 'table' then
                        local hit = map[wHash] or map[tostring(wHash)]
                        if hit and hit ~= '' then
                            if Config.Debug then print(('[mack-weaponcustomisation] %s weaponInHands[%s] -> %s'):format(res, wHash, hit)) end
                            return hit
                        end
                    end
                end
                return nil
            end)
            if ok and out then return out end
            Wait(100)
            tries = tries + 1
        end
    end
    if Config.Debug then print('[mack-weaponcustomisation] rsg-weapons export not available; tried:', table.concat(tried, ', ')) end

    -- Iterate configured providers
    if type(Config.SerialProviders) == 'table' then
        for _, prov in ipairs(Config.SerialProviders) do
            local resname = prov.resource
            local exp = prov.export
            local fields = prov.fields
            if resname and exp and GetResourceState(resname) == 'started' then
                local ok, out = pcall(function()
                    if exports[resname] and exports[resname][exp] then
                        return exports[resname][exp](exports[resname])
                    elseif exports[resname] and exports[resname]:__index(exp) then
                        return exports[resname]:__index(exp)()
                    else
                        -- generic colon-call
                        return (exports[resname] and exports[resname][exp]) and exports[resname][exp]() or nil
                    end
                end)
                if ok and out then
                    if type(out) == 'string' then
                        if Config.Debug then print(('[mack-weaponcustomisation] %s.%s -> %s'):format(resname, exp, out)) end
                        return out
                    elseif type(out) == 'table' then
                        if type(fields) == 'table' then
                            for _, p in ipairs(fields) do
                                local v = getByPath(out, p)
                                if v and v ~= '' then
                                    if Config.Debug then print(('[mack-weaponcustomisation] %s.%s %s -> %s'):format(resname, exp, p, v)) end
                                    return v
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if Config.AllowSerialPrompt then
        if Config.Debug then print('[mack-weaponcustomisation] Serial not found; showing manual prompt (allowed by config).') end
        local input = lib.inputDialog('Weapon Serial', {
            { type = 'input', label = 'Enter weapon serial', placeholder = 'e.g., 12ABC34D567EFGH', required = true }
        })
        if input and input[1] and input[1] ~= '' then
            return input[1]
        end
    end
    if Config.Debug then print('[mack-weaponcustomisation] Serial not found via exports; skipping prompt and returning nil.') end
    return nil
end

local function tryCallback(name, ...)
    -- Retry a few times in case server callback hasn’t registered yet
    local tries, last = 0, nil
    local args = { ... }
    while tries < 10 do
        local ok, res = pcall(function()
            return lib.callback.await(name, false, table.unpack(args))
        end)
        if ok and res ~= nil then return res end
        Wait(100)
        tries = tries + 1
    end
    return last
end

local compCatalog = nil
local compIndices = nil

-- Await an RSGCore callback (client-side)
local function awaitRSGCallback(name, ...)
    local p = promise.new()
    RSGCore.Functions.TriggerCallback(name, function(res)
        p:resolve(res)
    end, ...)
    return Citizen.Await(p)
end

local function getWeaponNameFromHash(wHash)
    return Citizen.InvokeNative(0x89CF5FF3D363311E, wHash, Citizen.ResultAsString())
end

local function buildSchemaFromCatalog(catalog)
    local schema = {}
    for cat, list in pairs(catalog or {}) do
        local n = (type(list) == 'table') and #list or 0
        if n > 0 then
            schema[cat] = n - 1 -- indices 0..(n-1); -1 means none, but UI clamps
        end
    end
    return schema
end

-- Collect a master list of all possible categories from config, for greyed-out rows
local function collectAllCategories()
    local seen, out = {}, {}
    local Shared = Config.Components and Config.Components.Shared or {}
    for _, groupTbl in pairs(Shared) do
        for cat, _ in pairs(groupTbl) do
            if not seen[cat] then seen[cat] = true; out[#out+1] = cat end
        end
    end
    local Specific = Config.Components and Config.Components.Specific or {}
    for _, weapTbl in pairs(Specific) do
        for cat, _ in pairs(weapTbl) do
            if not seen[cat] then seen[cat] = true; out[#out+1] = cat end
        end
    end
    table.sort(out)
    return out
end

local function indexesFromSaved(catalog, saved)
    local idx = {}
    if type(saved) ~= 'table' then return idx end
    for cat, name in pairs(saved) do
        local list = catalog[cat]
        if list then
            for i, comp in ipairs(list) do
                if comp == name then
                    idx[cat] = i - 1
                    break
                end
            end
        end
    end
    return idx
end

-- Lightweight orbit camera (no external dep)
local orbitCam = nil
local orbitAngle = 0.0
local camPanOffset = 0.0 -- additional side pan adjusted via UI
local camHeightOffset = 0.0 -- additional up/down tilt adjusted via UI
local camZoomOffset = 0.0   -- additional zoom (back/forward) adjusted via UI


local function getFocusPoint()
    local ped = PlayerPedId()
    local hand = GetEntityBoneIndexByName(ped, 'SKEL_R_Hand')
    if hand and hand ~= -1 then
        local hx, hy, hz = GetWorldPositionOfEntityBone(ped, hand)
        if hx and hy and hz then return hx, hy, hz end
    end
    local px, py, pz = table.unpack(GetEntityCoords(ped))
    return px, py, pz
end

local function openPreviewCam()
    if orbitCam then return end
    local ped = PlayerPedId()
    local wHash = GetPedCurrentHeldWeapon(ped)
    if not wHash or wHash == GetHashKey('WEAPON_UNARMED') then
        if Config.Debug then print('[mack-weaponcustomisation] skip preview cam: player unarmed') end
        return
    end
    local fx, fy, fz = getFocusPoint()
    if not fx or not fy or not fz then
        if Config.Debug then print('[mack-weaponcustomisation] cannot resolve hand/ped coords; skipping cam') end
        return
    end
    -- Place camera in front of the player using configured offsets
    local fwdx, fwdy, _ = table.unpack(GetEntityForwardVector(ped))
    local rightx, righty = -fwdy, fwdx
    local db = (Config.distBack or 0.7) + camZoomOffset
    local ds = (Config.distSide or 0.13) + camPanOffset
    local du = (Config.distUp or 0.05) + camHeightOffset
    local cx = fx + fwdx * db + rightx * ds
    local cy = fy + fwdy * db + righty * ds
    local cz = fz + du

    orbitCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(orbitCam, cx, cy, cz)
    PointCamAtCoord(orbitCam, fx, fy, fz)
    SetCamActive(orbitCam, true)
    SetCamFov(orbitCam, (Config.distFov or 60.0))
    RenderScriptCams(true, true, 400, true, true)
    -- No orbiting; keep camera fixed in front. Update aim to follow if target moves.
    CreateThread(function()
        while uiOpen and orbitCam do
            local nfx, nfy, nfz = getFocusPoint()
            PointCamAtCoord(orbitCam, nfx or fx, nfy or fy, nfz or fz)
            Wait(0)
        end
    end)
end

local function closePreviewCam()
    if orbitCam then
        RenderScriptCams(false, true, 400, true, true)
        DestroyCam(orbitCam, false)
        orbitCam = nil
    end
end

local function openUI()
    -- Try to detect serial but do not block the UI if missing; only require it on Save
    currentSerial = tryAutoDetectSerial()

    -- hide prompt text if visible
    if lib and lib.hideTextUI then pcall(lib.hideTextUI) end

    -- Build catalog (prefer rsg-weaponcomp export for accurate lists)
    compCatalog, compIndices = {}, {}
    local ped = PlayerPedId()
    local wHash = GetPedCurrentHeldWeapon(ped)
    if wHash and wHash ~= GetHashKey('WEAPON_UNARMED') then
        local wname = getWeaponNameFromHash(wHash)
        -- Restriction check
        for _, dis in ipairs(Config.WeaponRestriction or {}) do
            if dis == wname then
                notify('Weapon Customisation', 'This weapon cannot be customised here.', 'error')
                return
            end
        end
        -- Build from internal catalog (Shared + Specific). If you want to source from rsg-weaponcomp, we need its config copied here.
        local groupMap = {
            [GetHashKey('GROUP_REPEATER')] = 'LONGARM',
            [GetHashKey('GROUP_SHOTGUN')]  = 'SHOTGUN',
            [GetHashKey('GROUP_PISTOL')]   = 'SHORTARM',
            [GetHashKey('GROUP_REVOLVER')] = 'SHORTARM',
            [GetHashKey('GROUP_RIFLE')]    = 'LONGARM',
            [GetHashKey('GROUP_SNIPER')]   = 'LONGARM',
            [GetHashKey('GROUP_MELEE')]    = 'MELEE_BLADE',
            [GetHashKey('GROUP_BOW')]      = 'GROUP_BOW',
        }
        local groupHash = GetWeapontypeGroup(wHash)
        local group = groupMap[groupHash]
        local Shared = Config.Components and Config.Components.Shared or {}
        local Specific = Config.Components and Config.Components.Specific or {}
        local merged = {}
        if group and Shared[group] then
            for cat, list in pairs(Shared[group]) do
                merged[cat] = merged[cat] or {}
                for _, comp in ipairs(list) do merged[cat][#merged[cat]+1] = comp end
            end
        end
        if Specific[wname] then
            for cat, list in pairs(Specific[wname]) do
                merged[cat] = merged[cat] or {}
                for _, comp in ipairs(list) do merged[cat][#merged[cat]+1] = comp end
            end
        end
        compCatalog = merged
        if Config.Debug then
            local count = 0
            for _ in pairs(compCatalog) do count = count + 1 end
            print(('[mack-weaponcustomisation] catalog built for %s categories=%d'):format(wname, count))
        end
        
    end

    local reply = { ok = true, components = {}, components_before = {} }
    if currentSerial and currentSerial ~= '' then
        if Config.UseWeaponComp then
            local res = awaitRSGCallback('rsg-weaponcomp:server:getPlayerWeaponComponents', currentSerial)
            if type(res) == 'table' and type(res.components) == 'table' then
                reply = { ok = true, components = res.components, components_before = {} }
            end
        else
            reply = tryCallback('mack-weaponcustomisation:getComponents', currentSerial) or reply
        end
    end

    -- compute indices from saved names (if any)
    compIndices = indexesFromSaved(compCatalog, reply.components)

    local schema = buildSchemaFromCatalog(compCatalog)
    local allcats = collectAllCategories()

SendNUIMessage({ type = 'open', serial = currentSerial, payload = reply, schema = schema, catalog = compCatalog, indices = compIndices, price = (Config.Price or Config.price or {}), allcats = allcats, materials = Config.CustomMaterials or {}, weapon = wname })
    SetNuiFocus(true, true)
    uiOpen = true
    openPreviewCam()
end

local function closeUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'close' })
    uiOpen = false
    closePreviewCam()
end

local isNearShop = false

-- Public event to open from other resources (e.g., Bulletcraft target menu)
RegisterNetEvent('mack-weaponcustomisation-v2:client:open', function()
  openUI()
end)

-- Open Crafting UI via forwarded payload from Bulletpress
RegisterNetEvent('mack-weaponcustomisation-v2:client:openCraftingMenu', function(payload)
  -- payload: { crafting = [...], inventory = {...}, lang = {...} }
  SendNUIMessage({ type = 'craft:open', crafting = payload.crafting or {}, inventory = payload.inventory or {}, lang = payload.lang or {} })
  SetNuiFocus(true, true)
end)

-- Exported function so other resources can call exports['mack-weaponcustomisation-v2']:OpenCustomisation()
function OpenCustomisation()
  openUI()
end

-- NUI callbacks for crafting (migrated from bulletcraft)
RegisterNUICallback('startCrafting', function(data, cb)
  local action = data.actionType
  local item = data.receive
  local crafttime = tonumber(data.crafttime) or 5000
  local ingredients = data.ingredients or {}
  local name = data.name or item

  RSGCore.Functions.TriggerCallback('mm-bulletpress:server:checkingredients', function(hasRequired)
    if hasRequired then
      -- Start progress and complete crafting
      local ped = PlayerPedId()
      TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), crafttime, true, false, false, false)
      SendNUIMessage({ type = 'craft:startProgress', actionType = 'Crafting', duration = crafttime })
      RSGCore.Functions.Progressbar('press', 'crafting '..(name or ''), crafttime, false, true, {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
      }, {}, {}, {}, function() -- Done
          TriggerServerEvent('mm-bulletpress:server:finishcrafting', ingredients, item)
          TriggerServerEvent('j-reputations:server:addrep', 'crafting', 1)
          ClearPedTasks(ped)
      end, function() -- Cancel
          ClearPedTasks(ped)
      end)
      cb({ success = true })
    else
      -- Build missing list and notify via ox_lib
      local player = RSGCore.Functions.GetPlayerData()
      local inv = {}
      for _, it in pairs(player.items or {}) do inv[it.name] = (it.amount or 0) end
      local lines = {}
      for _, ing in ipairs(ingredients or {}) do
        local have = inv[ing.item] or 0
        if have < (ing.amount or 0) then
          local label = (RSGCore.Shared and RSGCore.Shared.Items and RSGCore.Shared.Items[ing.item] and RSGCore.Shared.Items[ing.item].label) or ing.item
          lines[#lines+1] = string.format('%s: %d needed, %d have', label, ing.amount or 0, have)
        end
      end
      if #lines > 0 and lib and lib.notify then
        lib.notify({ title = 'Missing Items', description = table.concat(lines, '\n'), type = 'error' })
      end
      cb({ success = false })
    end
  end, ingredients)
end)

RegisterNUICallback('cancelCrafting', function(_, cb)
  TriggerEvent('RSGCore:Client:CancelProgressbar')
  cb({})
end)

RegisterNUICallback('closeCrafting', function(_, cb)
  SetNuiFocus(false, false)
  SendNUIMessage({ type = 'craft:close' })
  cb({})
end)

-- (mm-bulletpress:crafting) event not needed; handled inline in startCrafting callback above

RegisterCommand(Config.Command, function()
    -- Job lock (optional)
    if Config.JobLock and Config.RequiredJob then
        local PlayerData = RSGCore.Functions.GetPlayerData()
        local jobName = PlayerData and PlayerData.job and PlayerData.job.name or nil
        if jobName ~= Config.RequiredJob then
            notify('Weapon Customisation', 'Only available to Gunsmith.', 'error')
            return
        end
    end
    openUI()
end, false)

-- Prompt loop
CreateThread(function()
    if not Config.UsePrompts or not Config.Shops or #Config.Shops == 0 then return end
    local shown = false
    while true do
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)
        local near = false
        for _, shop in ipairs(Config.Shops) do
            local d = #(pcoords - shop.coords)
            if d <= (shop.radius or 2.0) then
                near = true
                if uiOpen then
                    if shown and lib and lib.hideTextUI then lib.hideTextUI(); shown = false end
                else
                    if not shown and lib and lib.showTextUI then
                        lib.showTextUI('[ENTER] Open Weapon Customisation')
                        shown = true
                    end
                    -- ENTER to open
                    if IsControlJustPressed(0, 0xC7B5340A) then
                        openUI()
                    end
                end
                break
            end
        end
        if near then
            isNearShop = true
        else
            isNearShop = false
            if shown and lib and lib.hideTextUI then
                lib.hideTextUI()
                shown = false
            end
        end
        Wait(0)
    end
end)

-- ================= Bulletpress (client) =================
local SpawnedProps = {}

-- Spawn props near player and attach targets
CreateThread(function()
    while true do
        Wait(250)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        for i = 1, #Config.PlayerProps do
            local prop = Config.PlayerProps[i]
            local propVec = vector3(prop.x, prop.y, prop.z)
            local dist = #(pos - propVec)
            if dist < 50.0 then
                local exists = false
                for _, sp in ipairs(SpawnedProps) do if sp.id == prop.id then exists = true break end end
                if not exists then
                    local hash = prop.hash
                    if not HasModelLoaded(hash) then RequestModel(hash); while not HasModelLoaded(hash) do Wait(1) end end
                    local obj = CreateObject(hash, prop.x, prop.y, prop.z - 1.2, false, false, false)
                    SetEntityHeading(obj, prop.h)
                    SetEntityAsMissionEntity(obj, true)
                    PlaceObjectOnGroundProperly(obj)
                    Wait(500)
                    FreezeEntityPosition(obj, true)
                    SetModelAsNoLongerNeeded(hash)

exports['rsg-target']:AddTargetEntity(obj, {
                        options = {
                            { type='client', event='mm-bulletpress:client:openCraftingMenu', icon='fas fa-hammer', label='Craft Items', stashid = prop.id },
                            { type='client', event='mack-weaponcustomisation-v2:client:open', icon='fas fa-paint-brush', label='Weapon Customisation' },
                            { type='client', event='mm-bulletpress:client:distroystash', icon='fas fa-trash', label='Remove Bench', stashid = prop.id, entity = obj },
                        },
                        distance = 2
                    })
                    table.insert(SpawnedProps, { id = prop.id, obj = obj })
                end
            end
        end
    end
end)

RegisterNetEvent('mm-bulletpress:client:updatePropData', function(props)
    Config.PlayerProps = props or {}
end)

-- Request props on client start as a fallback in case we missed broadcast
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('mm-bulletpress:server:requestProps')
end)

RegisterNetEvent('mm-bulletpress:client:removePropObject', function(stashId)
    for i, sp in ipairs(SpawnedProps) do
        if sp.id == stashId and DoesEntityExist(sp.obj) then
            DeleteEntity(sp.obj)
            table.remove(SpawnedProps, i)
            break
        end
    end
end)

-- Crafting menu open (build payload locally and open v2 UI)
RegisterNetEvent('mm-bulletpress:client:openCraftingMenu', function(data)
    local recipes = {}
    for k, v in pairs(Config.pressRecipes or {}) do
        recipes[#recipes+1] = {
            key = k, name = v.name, ingredients = v.ingredients, crafttime = v.crafttime, receive = v.receive, category = v.category or 'Misc'
        }
    end
    table.sort(recipes, function(a,b) return (a.name or ''):lower() < (b.name or ''):lower() end)

    local player = RSGCore.Functions.GetPlayerData()
    local inventory = {}
    for _, item in pairs(player.items or {}) do inventory[item.name] = item.amount or 0 end

    local craftingData = {}
    for _, r in ipairs(recipes) do
        craftingData[#craftingData+1] = { title = r.name, ingredients = r.ingredients, receive = r.receive, giveamount = 1, crafttime = r.crafttime, category = r.category }
    end

SendNUIMessage({ type = 'craft:open', crafting = craftingData, inventory = inventory, items = (RSGCore and RSGCore.Shared and RSGCore.Shared.Items) or {}, lang = { categories='Categories', craftable_items='Craftable Items', item_details='Item Details', required_items='Required Items', craft='Craft', close='Close', missing_items='Missing Items', crafting='Crafting', in_progress='in progress', cancel='Cancel', needed='needed', you_have='you have', select_item_to_view_details='Select an item to view details' } })
    SetNuiFocus(true, true)
end)

-- Remove bench (destroy)

RegisterNetEvent('mm-bulletpress:client:distroystash', function(data)
    local input = lib.inputDialog('Destroy Stash', { { label='Are you sure?', type='select', options={ {value='yes', label='Yes'}, {value='no', label='No'} }, required=true } })
    if not input or input[1] ~= 'yes' then return end
    lib.progressBar({ duration = Config.DestroyTime, position='bottom', useWhileDead=false, canCancel=false, disableControl=true, label='Destroying...' })
    TriggerServerEvent('mm-bulletpress:server:destroyProp', data.stashid)
end)

-- Prop placement (prompts)
local CancelPrompt, SetPrompt, RotateLeftPrompt, RotateRightPrompt
local PromptPlacerGroup = GetRandomIntInRange(0, 0xffffff)

local function PromptDel()
    local str = Config.PromptCancelName
    CancelPrompt = PromptRegisterBegin(); PromptSetControlAction(CancelPrompt, 0xF84FA74F)
    PromptSetText(CancelPrompt, CreateVarString(10, 'LITERAL_STRING', str)); PromptSetEnabled(CancelPrompt, true)
    PromptSetVisible(CancelPrompt, true); PromptSetHoldMode(CancelPrompt, true); PromptSetGroup(CancelPrompt, PromptPlacerGroup)
    PromptRegisterEnd(CancelPrompt)
end
local function PromptSet()
    local str = Config.PromptPlaceName
    SetPrompt = PromptRegisterBegin(); PromptSetControlAction(SetPrompt, 0x07CE1E61)
    PromptSetText(SetPrompt, CreateVarString(10, 'LITERAL_STRING', str)); PromptSetEnabled(SetPrompt, true)
    PromptSetVisible(SetPrompt, true); PromptSetHoldMode(SetPrompt, true); PromptSetGroup(SetPrompt, PromptPlacerGroup)
    PromptRegisterEnd(SetPrompt)
end
local function PromptRotateLeft()
    local str = Config.PromptRotateLeft
    RotateLeftPrompt = PromptRegisterBegin(); PromptSetControlAction(RotateLeftPrompt, 0xA65EBAB4)
    PromptSetText(RotateLeftPrompt, CreateVarString(10, 'LITERAL_STRING', str)); PromptSetEnabled(RotateLeftPrompt, true)
    PromptSetVisible(RotateLeftPrompt, true); PromptSetStandardMode(RotateLeftPrompt, true); PromptSetGroup(RotateLeftPrompt, PromptPlacerGroup)
    PromptRegisterEnd(RotateLeftPrompt)
end
local function PromptRotateRight()
    local str = Config.PromptRotateRight
    RotateRightPrompt = PromptRegisterBegin(); PromptSetControlAction(RotateRightPrompt, 0xDEB34313)
    PromptSetText(RotateRightPrompt, CreateVarString(10, 'LITERAL_STRING', str)); PromptSetEnabled(RotateRightPrompt, true)
    PromptSetVisible(RotateRightPrompt, true); PromptSetStandardMode(RotateRightPrompt, true); PromptSetGroup(RotateRightPrompt, PromptPlacerGroup)
    PromptRegisterEnd(RotateRightPrompt)
end

CreateThread(function() PromptSet(); PromptDel(); PromptRotateLeft(); PromptRotateRight(); end)

local function PropPlacer(proptype, prop)
    local myPed = PlayerPedId(); local pos = GetEntityCoords(myPed)
    local hash = GetHashKey(prop)
    if not HasModelLoaded(hash) then RequestModel(hash); while not HasModelLoaded(hash) do Wait(5) end end
    local coords = GetEntityCoords(myPed); local _x,_y,_z = table.unpack(coords)
    local forward = GetEntityForwardVector(myPed); local x,y,z = table.unpack(pos - forward * -Config.ForwardDistance)
    local ox = x - _x; local oy = y - _y; local heading = 0.0

    local tempObj = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
    local tempObj2 = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
    AttachEntityToEntity(tempObj2, myPed, 0, ox, oy, 0.5, 0.0, 0.0, 0, true, false, false, false, false)
    SetEntityAlpha(tempObj, 180); SetEntityAlpha(tempObj2, 0)

    while true do
        Wait(5)
        local grp = CreateVarString(10, 'LITERAL_STRING', Config.PromptGroupName)
        PromptSetActiveGroupThisFrame(PromptPlacerGroup, grp)
        AttachEntityToEntity(tempObj, myPed, 0, ox, oy, -0.8, 0.0, 0.0, heading, true, false, false, false, false)
        if IsControlPressed(1, 0xA65EBAB4) then heading = heading - 1 end
        if IsControlPressed(1, 0xDEB34313) then heading = heading + 1 end
        local pPos = GetEntityCoords(tempObj2)
        if PromptHasHoldModeCompleted(SetPrompt) then
            FreezeEntityPosition(PlayerPedId(), true)
            TriggerServerEvent('mm-bulletpress:server:newProp', proptype, pPos, heading, hash)
            DeleteEntity(tempObj2); DeleteEntity(tempObj); FreezeEntityPosition(PlayerPedId(), false)
            break
        end
        if PromptHasHoldModeCompleted(CancelPrompt) then
            DeleteEntity(tempObj2); DeleteEntity(tempObj); SetModelAsNoLongerNeeded(hash)
            break
        end
    end
end

RegisterNetEvent('mm-bulletpress:client:createstash', function(proptype, prop)
    PropPlacer(proptype, prop)
end)

-- Debug command to print detected serial
RegisterCommand('mackwc_serial', function()
    local s = tryAutoDetectSerial()
    notify('Weapon Customisation', ('Detected serial: %s'):format(s or 'nil'), s and 'inform' or 'error')
end, false)

-- Deep diagnostic: dump rsg-weapons mapping and current hash
RegisterCommand('mackwc_dump', function()
    local ped = PlayerPedId()
    local wHash = GetPedCurrentHeldWeapon(ped)
    print(('[mack-weaponcustomisation] dump: wHash=%s tostring=%s unarmed=%s'):
        format(tostring(wHash), tostring(wHash and tostring(wHash) or 'nil'), tostring(wHash == GetHashKey('WEAPON_UNARMED'))))
    local names = { Config.RSGWeaponsResourceName, 'rsg-weapons', 'rsg_weapons', 'rsgweapons', 'RSG-Weapons' }
    local seen = {}
    for _, res in ipairs(names) do
        if res and res ~= '' and not seen[res] then
            seen[res] = true
            local ok, map = pcall(function()
                if exports[res] and exports[res].weaponInHands then
                    return exports[res]:weaponInHands()
                end
                return nil
            end)
            print(('[mack-weaponcustomisation] dump: res=%s ok=%s haveExport=%s'):format(res, tostring(ok), tostring(ok and map ~= nil)))
            if type(map) == 'table' then
                local count = 0
                for k,v in pairs(map) do
                    count = count + 1
                    if count <= 10 then
                        print(('[mack-weaponcustomisation] map[%s]=%s (keytype=%s)'):format(tostring(k), tostring(v), type(k)))
                    end
                end
                print(('[mack-weaponcustomisation] map size: %d | map[wHash]=%s | map[tostring(wHash)]=%s'):
                    format(count, tostring(map[wHash]), tostring(map[tostring(wHash)])))
            end
        end
    end
end, false)

-- NUI callbacks
RegisterNUICallback('exit', function(_, cb)
    closeUI()
    cb({ ok = true })
end)

RegisterNUICallback('reset', function(_, cb)
    if Config.UseWeaponComp then
        TriggerEvent('rsg-weaponcomp:client:clearAllHeld')
    else
        -- Clear applied components from held weapon using current catalog
        if compCatalog then
            for cat, list in pairs(compCatalog) do
                for _, compName in ipairs(list) do
                    localRemoveComponent(compName)
                end
            end
        end
    end
    cb({ ok = true })
end)

RegisterNUICallback('save', function(data, cb)
    local indices = type(data and data.components) == 'table' and data.components or {}
    if not currentSerial then
        currentSerial = tryAutoDetectSerial()
        if not currentSerial then
            SendNUIMessage({ type = 'saved', ok = false, error = 'no_serial' })
            cb({ ok = false, error = 'no_serial' })
            return
        end
    end
    -- build selection names from indices
    local selection = {}
    for cat, idx in pairs(indices) do
        local i = tonumber(idx)
        if i and i >= 0 then
            local list = compCatalog and compCatalog[cat]
            if list and list[i+1] then
                selection[cat] = list[i+1]
            end
        end
    end

    if Config.SaveViaWeaponComp then
        -- compute price (0 for Save path)
        local price = 0.0
        local ped = PlayerPedId()
        local wHash = GetPedCurrentHeldWeapon(ped)
        TriggerServerEvent('rsg-weaponcomp:server:price', price, wHash, currentSerial, selection, nil)
        SendNUIMessage({ type = 'saved', ok = true, price = price })
        notify('Weapon Customisation', 'Saved (weaponcomp).', 'success')
        cb({ ok = true, price = price })
        return
    end

    -- Fallback: local DB save
    local price = 0.0
    local pmap = Config.Price or Config.price or {}
    if type(pmap) == 'table' then
        for cat, idx in pairs(indices) do
            if tonumber(idx or -1) and tonumber(idx) >= 0 then
                price = price + (pmap[cat] or 0.0)
            end
        end
    end
    TriggerServerEvent('mack-weaponcustomisation:saveComponents', currentSerial, indices)
    SendNUIMessage({ type = 'saved', ok = true, price = price })
    notify('Weapon Customisation', 'Saved.', 'success')
    cb({ ok = true, price = price })
end)

RegisterNUICallback('pay', function(data, cb)
    local indices = type(data and data.components) == 'table' and data.components or {}
    if not currentSerial then
        currentSerial = tryAutoDetectSerial()
        if not currentSerial then
            SendNUIMessage({ type = 'saved', ok = false, error = 'no_serial' })
            cb({ ok = false, error = 'no_serial' })
            return
        end
    end

    -- build selection names from indices
    local selection = {}
    for cat, idx in pairs(indices) do
        local i = tonumber(idx)
        if i and i >= 0 then
            local list = compCatalog and compCatalog[cat]
            if list and list[i+1] then
                selection[cat] = list[i+1]
            end
        end
    end

    if Config.SaveViaWeaponComp then
        -- compute price using local Config.Price
        local price = 0.0
        local pmap = Config.Price or Config.price or {}
        if type(pmap) == 'table' then
            for cat, idx in pairs(indices) do
                if tonumber(idx or -1) and tonumber(idx) >= 0 then
                    price = price + (pmap[cat] or 0.0)
                end
            end
        end
        local ped = PlayerPedId()
        local wHash = GetPedCurrentHeldWeapon(ped)
        TriggerServerEvent('rsg-weaponcomp:server:price', price, wHash, currentSerial, selection, nil)
        cb({ ok = true })
        return
    end

    -- Fallback to local server payment/save
    TriggerServerEvent('mack-weaponcustomisation:payAndSave', currentSerial, indices)
    cb({ ok = true })
end)

RegisterNetEvent('mack-weaponcustomisation:paid', function(ok, price, message)
    SendNUIMessage({ type = 'saved', ok = ok, price = price, error = message })
    if ok then
        if price and price > 0 then
            notify('Weapon Customisation', ('Paid & Saved. Charged: $%.2f'):format(price), 'success')
        else
            notify('Weapon Customisation', 'Paid & Saved.', 'success')
        end
    else
        notify('Weapon Customisation', 'Payment failed: ' .. tostring(message or 'unknown'), 'error')
    end
end)

-- Preview hooks (placeholder)
-- Local component apply/clear (no dependency)
local function localAttachComponent(compName)
    if not compName or compName == '' then return end
    local ped = PlayerPedId()
    local wHash = GetPedCurrentHeldWeapon(ped)
    if not wHash or wHash == GetHashKey('WEAPON_UNARMED') then return end
    local compHash = GetHashKey(compName)
    if compHash == 0 then return end
    local mdl = GetWeaponComponentTypeModel(compHash)
    if mdl and mdl ~= 0 then RequestModel(mdl); while not HasModelLoaded(mdl) do Wait(0) end end
    GiveWeaponComponentToEntity(ped, compHash, wHash, true)
    ApplyShopItemToPed(ped, compHash, true, true, true)
    if mdl and mdl ~= 0 then SetModelAsNoLongerNeeded(mdl) end
    Citizen.InvokeNative(0x76A18844E743BF91, ped)
end

local function localRemoveComponent(compName)
    if not compName or compName == '' then return end
    local ped = PlayerPedId()
    local wHash = GetPedCurrentHeldWeapon(ped)
    if not wHash or wHash == GetHashKey('WEAPON_UNARMED') then return end
    local compHash = GetHashKey(compName)
    if compHash == 0 then return end
    RemoveWeaponComponentFromPed(ped, compHash, wHash)
    Citizen.InvokeNative(0x76A18844E743BF91, ped)
end

RegisterNUICallback('preview', function(data, cb)
    local key = data and data.key
    local prevIndex = tonumber(data and data.prev)
    local nextIndex = tonumber(data and data.value)
    if not key or not compCatalog or not compCatalog[key] then cb({ ok = false }); return end
    local list = compCatalog[key]

    -- Clamp indices to valid range (-1..max)
    local max = #list - 1
    if prevIndex then prevIndex = math.max(-1, math.min(max, prevIndex)) end
    if nextIndex then nextIndex = math.max(-1, math.min(max, nextIndex)) end

    local prevName = (prevIndex and prevIndex >= 0 and list[prevIndex+1]) or nil
    local nextName = (nextIndex and nextIndex >= 0 and list[nextIndex+1]) or nil

    if Config.UseWeaponComp then
        TriggerEvent('rsg-weaponcomp:client:applyComponentPair', prevName, nextName)
    else
        if prevName then localRemoveComponent(prevName) end
        if nextName then localAttachComponent(nextName) end
    end
    cb({ ok = true })
end)

RegisterNUICallback('camera', function(data, cb)
    -- currently unused (no-op)
    cb({ ok = true })
end)

RegisterNUICallback('camera_pan', function(data, cb)
    local delta = tonumber(data and data.delta) or 0.0
    camPanOffset = camPanOffset + delta
    if camPanOffset > 0.8 then camPanOffset = 0.8 elseif camPanOffset < -0.8 then camPanOffset = -0.8 end
    local ped = PlayerPedId()
    if orbitCam then
        local fx, fy, fz = getFocusPoint()
        local fwdx, fwdy, _ = table.unpack(GetEntityForwardVector(ped))
        local rightx, righty = -fwdy, fwdx
        local db = (Config.distBack or 0.7) + camZoomOffset
        local ds = (Config.distSide or 0.13) + camPanOffset
        local du = (Config.distUp or 0.05) + camHeightOffset
        local cx = fx + fwdx * db + rightx * ds
        local cy = fy + fwdy * db + righty * ds
        local cz = fz + du
        SetCamCoord(orbitCam, cx, cy, cz)
        PointCamAtCoord(orbitCam, fx, fy, fz)
    end
    cb({ ok = true, pan = camPanOffset })
end)

RegisterNUICallback('camera_tilt', function(data, cb)
    local delta = tonumber(data and data.delta) or 0.0
    camHeightOffset = camHeightOffset + delta
    if camHeightOffset > 0.6 then camHeightOffset = 0.6 elseif camHeightOffset < -0.3 then camHeightOffset = -0.3 end
    local ped = PlayerPedId()
    if orbitCam then
        local fx, fy, fz = getFocusPoint()
        local fwdx, fwdy, _ = table.unpack(GetEntityForwardVector(ped))
        local rightx, righty = -fwdy, fwdx
        local db = (Config.distBack or 0.7) + camZoomOffset
        local ds = (Config.distSide or 0.13) + camPanOffset
        local du = (Config.distUp or 0.05) + camHeightOffset
        local cx = fx + fwdx * db + rightx * ds
        local cy = fy + fwdy * db + righty * ds
        local cz = fz + du
        SetCamCoord(orbitCam, cx, cy, cz)
        PointCamAtCoord(orbitCam, fx, fy, fz)
    end
    cb({ ok = true, height = camHeightOffset })
end)

RegisterNUICallback('camera_zoom', function(data, cb)
    local delta = tonumber(data and data.delta) or 0.0
    camZoomOffset = camZoomOffset + delta
    if camZoomOffset > 1.0 then camZoomOffset = 1.0 elseif camZoomOffset < -0.5 then camZoomOffset = -0.5 end
    local ped = PlayerPedId()
    if orbitCam then
        local fx, fy, fz = getFocusPoint()
        local fwdx, fwdy, _ = table.unpack(GetEntityForwardVector(ped))
        local rightx, righty = -fwdy, fwdx
        local db = (Config.distBack or 0.7) + camZoomOffset
        local ds = (Config.distSide or 0.13) + camPanOffset
        local du = (Config.distUp or 0.05) + camHeightOffset
        local cx = fx + fwdx * db + rightx * ds
        local cy = fy + fwdy * db + righty * ds
        local cz = fz + du
        SetCamCoord(orbitCam, cx, cy, cz)
        PointCamAtCoord(orbitCam, fx, fy, fz)
    end
    cb({ ok = true, zoom = camZoomOffset })
end)
