Config = {}

-- Command to open the customisation flow (temporary, until full NUI is added)
Config.Command = 'mackwc'

-- Toggle debug prints
Config.Debug = true

-- Allow manual serial prompt if auto-detection fails
Config.AllowSerialPrompt = true

-- Prompt-based interaction (optional)
Config.UsePrompts = true
Config.JobLock = false
Config.RequiredJob = nil -- e.g. 'valweaponsmith'

-- Optional Discord logging
Config.EnableDiscordLog = false
Config.DiscordWebhook = '' -- set to your webhook URL to enable


-- Payment settings (money). If using materials for customisation, set EnablePayment=false
Config.EnablePayment = false
Config.PayAccount = 'cash' -- 'cash' or 'bank' depending on your economy

-- Use materials to apply customisation instead of money
Config.UseMaterialsForCustomise = true

-- Camera offsets (tweak to frame the weapon in front of player)
-- Increase distBack to zoom out, increase distSide to shift camera to player right.
Config.distBack = 0.95   -- was ~0.7
Config.distSide = -0.22  -- negative shifts camera to player's LEFT (was +0.22 to the right)
Config.distUp   = 0.12   -- was ~0.05 (raise a little more)
Config.distFov  = 68.0   -- was ~60.0, slightly wider view

-- Use rsg-weaponcomp for live preview apply/remove (better visuals for wraps/skins)
Config.UseWeaponComp = false

-- Save via rsg-weaponcomp (writes to weapon item info and plays its animation)
Config.SaveViaWeaponComp = false

-- Use ox_lib notifications
Config.Notify = function(title, description, type)
    if lib and lib.notify then
        lib.notify({ title = title, description = description, type = type or 'inform' })
    else
        print(('[%s] %s'):format(title or 'mack-weaponcustomisation', description or ''))
    end
end

-- Database table (must match your SQL)
Config.Table = 'player_weapons'

-- Simple default schema; replace/extend per-weapon later
Config.Schema = {
    defaults = {
        GRIP = 6,
        SIGHT = 3,
        BARREL = 3,
        WRAP = 6,
    },
    -- perWeapon example (use weapon hash or name keys if needed)
    perWeapon = {
        -- ['WEAPON_REVOLVER_CATTLEMAN'] = { GRIP = 6, SIGHT = 2, BARREL = 2 },
    }
}

-- Optional explicit resource name override if your rsg-weapons resource has a custom folder/name
Config.RSGWeaponsResourceName = 'rsg-weapons'

-- Serial providers (order matters). Adjust to match your environment.
-- Each entry can specify:
--   resource: resource name to check is started
--   export: export function name to call (via exports[resource]:export())
--   fields: list of nested fields to check when export returns a table (e.g. { 'serial', 'metadata.serial' })
Config.SerialProviders = {
    { resource = 'rsg-weapons', export = 'GetCurrentWeaponSerial' },
    { resource = 'rsg-weaponcomp', export = 'GetCurrentWeaponSerial' },
    { resource = 'rsg-inventory', export = 'GetCurrentWeapon', fields = { 'serial', 'metadata.serial' } },
    { resource = 'rsg-inventory', export = 'GetCurrentWeaponData', fields = { 'serial', 'metadata.serial' } },
}

-- Optional prompt zones (Valentine example). Disabled by default unless UsePrompts=true
Config.Shops = {
    { name = 'Valentine Gunsmith', coords = vector3(-287.37, 764.13, 118.89), radius = 2.2, job = 'valweaponsmith',
      Cameras = {
        ['LONGARM'] = { basePos = vector3(-281.01, 779.91, 120.54), baseRot = vector3(-85.57, 0.0, 179.63), grip = vector2(-0.50, 0.0), frame = vector2(-0.30, -0.05), barrel = vector2(0.10, -0.05) },
        ['SHOTGUN'] = { basePos = vector3(-281.08, 779.78, 120.54), baseRot = vector3(-85.57, 0.0, 179.63), grip = vector2(-0.50, 0.15), frame = vector2(-0.30, 0.05), barrel = vector2(0.05, 0.05) },
        ['SHORTARM'] = { basePos = vector3(-281.01, 779.91, 120.54), baseRot = vector3(-85.57, 0.0, 179.63), grip = vector2(-0.30, -0.05), frame = vector2(-0.30, -0.05), barrel = vector2(-0.15, -0.05) },
        ['GROUP_BOW'] = { basePos = vector3(-281.01, 779.91, 120.54), baseRot = vector3(-85.57, 0.0, 179.63), grip = vector2(-0.50, 0.0), frame = vector2(-0.30, -0.05), barrel = vector2(0.10, -0.05) },
        ['MELEE_BLADE'] = { basePos = vector3(-281.11, 779.81, 120.25), baseRot = vector3(-85.57, 0.0, 179.63), grip = vector2(0.15, -0.50), frame = vector2(0.15, -0.30), barrel = vector2(0.0, 0.15) },
      }
    },
}

-- Optional restriction list to prevent customisation on certain weapons
Config.WeaponRestriction = {
  'WEAPON_MELEE_KNIFE_CIVIL_WAR',
  'WEAPON_MELEE_KNIFE_JAWBONE',
  'WEAPON_MELEE_KNIFE_MINER',
  'WEAPON_MELEE_KNIFE_VAMPIRE',
  'WEAPON_MELEE_CLEAVER',
  'WEAPON_MELEE_HATCHET',
  'WEAPON_MELEE_HATCHET_DOUBLE_BIT',
  'WEAPON_MELEE_HATCHET_HEWING',
  'WEAPON_MELEE_HATCHET_HUNTER',
  'WEAPON_MELEE_HATCHET_VIKING',
  'WEAPON_THROWN_TOMAHAWK',
  'WEAPON_THROWN_THROWING_KNIVES',
  'WEAPON_THROWN_DYNAMITE',
  'WEAPON_KIT_BINOCULARS',
  'WEAPON_LASSO',
  'WEAPON_LASSO_REINFORCED',
  'WEAPON_REVOLVER_CATTLEMAN_MEXICAN',
  'WEAPON_REVOLVER_NAVY_CROSSOVER',
}

