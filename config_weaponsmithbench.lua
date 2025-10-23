Config = Config or {}

-- Dynamic props owned by players (synced from DB). Server will merge entries here on load.
Config.PlayerProps = Config.PlayerProps or {}

-- Prop placement prompt labels and distances
Config.ForwardDistance = 1.5
Config.PromptGroupName = 'Place bench'
Config.PromptCancelName = 'Cancel'
Config.PromptPlaceName = 'Place'
Config.PromptRotateLeft = 'Rotate Left'
Config.PromptRotateRight = 'Rotate Right'

-- Bench settings
Config.EnableVegModifier = true
Config.StashMaxWeight    = 5000000
Config.StashMaxSlots     = 60
Config.DestroyTime       = 10000
Config.MaxStashes        = 2
Config.StashProp         = 'p_workbench01x'

-- Optional map blip (unused by default)
Config.Blip = Config.Blip or { blipName = '', blipSprite = '', blipScale = 0.2, blipColour = 'BLIP_MODIFIER_MP_COLOR_6' }

-- Crafting recipes (ported from mack-bulletcraft-v2)
-- This is the full table migrated from the old config_bulletpress.lua.
Config.pressRecipes = {
    ["shellcasing"] = {
        name = 'Box Of Shell Casings',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "copperore", amount = 2 },
        },
        receive = "shellcasing"
    },
    ["gunpowder"] = {
        name = 'Gun Powder',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "coal", amount = 2 },
        },
        receive = "gunpowder"
    },
    ["weapon_melee_machete"] = {
        name = 'Machete',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_machete"
    },
    ['tnt'] = {
        name = "TNT",
        crafttime = 10000,
        category = "Explosives",
        ingredients = {
            [1] = { item = 'bolts', amount = 1 },
            [2] = { item = 'wood', amount = 2 },
            [3] = { item = "gunpowder", amount = 3 }
        },
        receive = 'tnt'
    },
    ["ammo_box_revolver"] = {
        name = 'Revolver - Box of Standard Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_revolver"
    },
    ["ammo_box_revolver_express"] = {
        name = 'Revolver - Box of Express Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_revolver_express"
    },
    ["ammo_box_revolver_velocity"] = {
        name = 'Revolver - Box of High Velocity Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_revolver_velocity"
    },
    ["ammo_box_revolver_splitpoint"] = {
        name = 'Revolver - Box of Split Point Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 3 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_revolver_splitpoint"
    },
    ["ammo_box_pistol"] = {
        name = 'Pistol - Box of Standard Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_pistol"
    },
    ["ammo_box_pistol_express"] = {
        name = 'Pistol - Box of Express Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_pistol_express"
    },
    ["ammo_box_pistol_velocity"] = {
        name = 'Pistol - Box of High Velocity Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_pistol_velocity"
    },
    ["ammo_box_pistol_splitpoint"] = {
        name = 'Pistol - Box of Split Point Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 3 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_pistol_splitpoint"
    },
    ["ammo_box_repeater"] = {
        name = 'Repeater - Box of Standard Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_repeater"
    },
    ["ammo_box_repeater_express"] = {
        name = 'Repeater - Box of Express Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_repeater_express"
    },
    ["ammo_box_repeater_velocity"] = {
        name = 'Repeater - Box of High Velocity Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_repeater_velocity"
    },
    ["ammo_box_repeater_splitpoint"] = {
        name = 'Repeater - Box of Split Point Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 3 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_repeater_splitpoint"
    },
    ["ammo_box_rifle"] = {
        name = 'Rifle - Box of Standard Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_rifle"
    },
    ["ammo_box_rifle_express"] = {
        name = 'Rifle - Box of Express Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_rifle_express"
    },
    ["ammo_box_rifle_velocity"] = {
        name = 'Rifle - Box of High Velocity Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_rifle_velocity"
    },
    ["ammo_box_rifle_splitpoint"] = {
        name = 'Rifle - Box of Split Point Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 3 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_rifle_splitpoint"
    },
    ["ammo_box_shotgun"] = {
        name = 'Shotgun - Box of Standard Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 1 },
            [2] = { item = "leadore", amount = 2 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_shotgun"
    },
    ["ammo_box_shotgun_slug"] = {
        name = 'Shotgun - Box of Slug Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 2 },
            [2] = { item = "leadore", amount = 3 },
            [3] = { item = "shellcasing", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_shotgun_slug"
    },
    ["ammo_box_rifle_elephant"] = {
        name = 'Rifle - Box of Elephant Rifle Ammo',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "gunpowder", amount = 3 },
            [2] = { item = "leadore", amount = 4 },
            [3] = { item = "shellcasing", amount = 2 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_box_rifle_elephant"
    },
    ["ammo_arrow"] = {
        name = 'Standard Arrows',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "feathers", amount = 1 },
            [3] = { item = "ironore", amount = 1 },
            [4] = { item = "oilcan", amount = 1 }
        },
        receive = "ammo_arrow"
    },
    ["ammo_arrow_fire"] = {
        name = 'Fire Arrows',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "feathers", amount = 1 },
            [3] = { item = "ironore", amount = 1 },
            [4] = { item = "gunpowder", amount = 1 }
        },
        receive = "ammo_arrow_fire"
    },
    ["ammo_arrow_poison"] = {
        name = 'Poison Arrows',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "feathers", amount = 1 },
            [3] = { item = "ironore", amount = 1 },
            [4] = { item = "morphine", amount = 1 }
        },
        receive = "ammo_arrow_poison"
    },
    ["ammo_arrow_dynamite"] = {
        name = 'Explosive Arrows',
        crafttime = 5000,
        category = "Ammunition",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "feathers", amount = 1 },
            [3] = { item = "ironore", amount = 1 },
            [4] = { item = "tnt", amount = 1 }
        },
        receive = "ammo_arrow_dynamite"
    },
    ["trigger"] = {
        name = 'Trigger',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "ironore", amount = 1 }
        },
        receive = "trigger"
    },
    ["hammer"] = {
        name = 'Hammer',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "ironore", amount = 1 }
        },
        receive = "hammer"
    },
    ["barrel"] = {
        name = 'Barrel',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "iron_bar", amount = 1 }
        },
        receive = "barrel"
    },
    ["spring"] = {
        name = 'Spring',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "ironore", amount = 1 }
        },
        receive = "spring"
    },
    ["frame"] = {
        name = 'Frame',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "iron_bar", amount = 1 }
        },
        receive = "frame"
    },
    ["grip"] = {
        name = 'Grip',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "wood", amount = 2 }
        },
        receive = "grip"
    },
    ["cylinder"] = {
        name = 'Cylinder',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "iron_bar", amount = 1 }
        },
        receive = "cylinder"
    },
    ["stock"] = {
        name = 'Stock',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "iron_bar", amount = 1 }
        },
        receive = "stock"
    },
    ["sight"] = {
        name = 'Sight',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "ironore", amount = 1 }
        },
        receive = "sight"
    },
    ["bolt"] = {
        name = 'Bolt',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "iron_bar", amount = 2 }
        },
        receive = "bolt"
    },
    ["action"] = {
        name = 'Action',
        crafttime = 5000,
        category = "Components",
        ingredients = {
            [1] = { item = "steel", amount = 2 }
        },
        receive = "action"
    },
    ["weapon_revolver_cattleman"] = {
        name = 'Cattleman Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_cattleman"
    },
    ["weapon_revolver_cattleman_mexican"] = {
        name = 'Cattleman Mexican Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_cattleman_mexican"
    },
    ["weapon_revolver_doubleaction_gambler"] = {
        name = 'Double-Action Gambler Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_doubleaction_gambler"
    },
    ["weapon_revolver_schofield"] = {
        name = 'Schofield Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_schofield"
    },
    ["weapon_revolver_lemat"] = {
        name = 'LeMat Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_lemat"
    },
    ["weapon_revolver_navy"] = {
        name = 'Navy Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_navy"
    },
    ["weapon_revolver_navy_crossover"] = {
        name = 'Navy Crossover Revolver',
        crafttime = 10000,
        category = "Revolvers",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_revolver_navy_crossover"
    },
    ["weapon_pistol_volcanic"] = {
        name = 'Volcanic Pistol',
        crafttime = 10000,
        category = "Pistols",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_pistol_volcanic"
    },
    ["weapon_pistol_m1899"] = {
        name = 'M1899 Pistol',
        crafttime = 10000,
        category = "Pistols",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_pistol_m1899"
    },
    ["weapon_pistol_mauser"] = {
        name = 'Mauser Pistol',
        crafttime = 10000,
        category = "Pistols",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_pistol_mauser"
    },
    ["weapon_pistol_semiauto"] = {
        name = 'Semi-Auto Pistol',
        crafttime = 10000,
        category = "Pistols",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_pistol_semiauto"
    },
    ["weapon_repeater_carbine"] = {
        name = 'Carbine Repeater',
        crafttime = 15000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_repeater_carbine"
    },
    ["weapon_repeater_winchester"] = {
        name = 'Winchester Repeater',
        crafttime = 15000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_repeater_winchester"
    },
    ["weapon_repeater_henry"] = {
        name = 'Henry Repeater',
        crafttime = 15000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_repeater_henry"
    },
    ["weapon_repeater_evans"] = {
        name = 'Evans Repeater',
        crafttime = 15000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_repeater_evans"
    },
    ["weapon_rifle_varmint"] = {
        name = 'Varmint Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_rifle_varmint"
    },
    ["weapon_rifle_springfield"] = {
        name = 'Springfield Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_rifle_springfield"
    },
    ["weapon_rifle_boltaction"] = {
        name = 'Bolt-Action Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_rifle_boltaction"
    },
    ["weapon_rifle_elephant"] = {
        name = 'Elephant Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_rifle_elephant"
    },
    ["weapon_shotgun_doublebarrel"] = {
        name = 'Double-Barrel Shotgun',
        crafttime = 15000,
        category = "Shotguns",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 2 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_shotgun_doublebarrel"
    },
    ["weapon_shotgun_doublebarrel_exotic"] = {
        name = 'Exotic Double-Barrel Shotgun',
        crafttime = 15000,
        category = "Shotguns",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 2 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_shotgun_doublebarrel_exotic"
    },
    ["weapon_shotgun_sawedoff"] = {
        name = 'Sawedoff Shotgun',
        crafttime = 15000,
        category = "Shotguns",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 2 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_shotgun_sawedoff"
    },
    ["weapon_shotgun_semiauto"] = {
        name = 'Semi-Auto Shotgun',
        crafttime = 15000,
        category = "Shotguns",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 2 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_shotgun_semiauto"
    },
    ["weapon_shotgun_pump"] = {
        name = 'Pump-Action Shotgun',
        crafttime = 15000,
        category = "Shotguns",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 2 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_shotgun_pump"
    },
    ["weapon_shotgun_repeating"] = {
        name = 'Repeating Shotgun',
        crafttime = 15000,
        category = "Shotguns",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 2 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_shotgun_repeating"
    },
    ["weapon_sniperrifle_rollingblock"] = {
        name = 'Rolling Block Sniper Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "sight", amount = 1 },
            [7] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_sniperrifle_rollingblock"
    },
    ["weapon_sniperrifle_rollingblock_exotic"] = {
        name = 'Exotic Rolling Block Sniper Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "sight", amount = 1 },
            [7] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_sniperrifle_rollingblock_exotic"
    },
    ["weapon_sniperrifle_carcano"] = {
        name = 'Carcano Sniper Rifle',
        crafttime = 20000,
        category = "Rifles",
        ingredients = {
            [1] = { item = "frame", amount = 1 },
            [2] = { item = "barrel", amount = 1 },
            [3] = { item = "cylinder", amount = 1 },
            [4] = { item = "trigger", amount = 1 },
            [5] = { item = "grip", amount = 1 },
            [6] = { item = "sight", amount = 1 },
            [7] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_sniperrifle_carcano"
    },
    ["weapon_bow"] = {
        name = 'Bow',
        crafttime = 10000,
        category = "Ranged Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 3 },
            [2] = { item = "twine", amount = 1 }
        },
        receive = "weapon_bow"
    },
    ["weapon_bow_improved"] = {
        name = 'Improved Bow',
        crafttime = 10000,
        category = "Ranged Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 3 },
            [2] = { item = "twine", amount = 1 },
            [3] = { item = "steel", amount = 1 }
        },
        receive = "weapon_bow_improved"
    },
    ["weapon_lasso"] = {
        name = 'Lasso',
        crafttime = 5000,
        category = "Ranged Weapons",
        ingredients = {
            [1] = { item = "twine", amount = 1 }
        },
        receive = "weapon_lasso"
    },
    ["weapon_lasso_reinforced"] = {
        name = 'Reinforced Lasso',
        crafttime = 5000,
        category = "Ranged Weapons",
        ingredients = {
            [1] = { item = "twine", amount = 1 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_lasso_reinforced"
    },
    ["weapon_melee_knife"] = {
        name = 'Knife',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 1 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_knife"
    },
    ["weapon_melee_knife_jawbone"] = {
        name = 'Jawbone Knife',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 1 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_knife_jawbone"
    },
    ["weapon_melee_knife_rustic"] = {
        name = 'Rustic Knife',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 1 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_knife_rustic"
    },
    ["weapon_melee_knife_horror"] = {
        name = 'Horror Knife',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 1 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_knife_horror"
    },
    ["weapon_melee_hatchet_hunter"] = {
        name = 'Hunter Hatchet',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_hatchet_hunter"
    },
    ["weapon_melee_hatchet_double_bit"] = {
        name = 'Double Bit Hatchet',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_hatchet_double_bit"
    },
    ["weapon_melee_machete_horror"] = {
        name = 'Horror Machete',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_machete_horror"
    },
    ["weapon_melee_hammer"] = {
        name = 'Hammer',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "ironore", amount = 1 }
        },
        receive = "weapon_melee_hammer"
    },
    ["weapon_melee_cleaver"] = {
        name = 'Cleaver',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 1 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_cleaver"
    },
    ["weapon_melee_lantern"] = {
        name = 'Lantern',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "ironore", amount = 1 },
            [2] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_melee_lantern"
    },
    ["weapon_melee_davy_lantern"] = {
        name = 'Davy Lantern',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "ironore", amount = 1 },
            [2] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_melee_davy_lantern"
    },
    ["weapon_melee_lantern_halloween"] = {
        name = 'Halloween Lantern',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "ironore", amount = 1 },
            [2] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_melee_lantern_halloween"
    },
    ["weapon_melee_torch"] = {
        name = 'Wooden Torch',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_melee_torch"
    },
    ["weapon_melee_hatchet"] = {
        name = 'Hatchet',
        crafttime = 5000,
        category = "Melee Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_melee_hatchet"
    },
    ["weapon_thrown_throwing_knives"] = {
        name = 'Throwing Knives',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "steel", amount = 1 },
            [2] = { item = "wood", amount = 1 }
        },
        receive = "weapon_thrown_throwing_knives"
    },
    ["weapon_thrown_tomahawk"] = {
        name = 'Tomahawk',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_thrown_tomahawk"
    },
    ["weapon_thrown_tomahawk_ancient"] = {
        name = 'Ancient Tomahawk',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "wood", amount = 2 },
            [2] = { item = "steel", amount = 1 }
        },
        receive = "weapon_thrown_tomahawk_ancient"
    },
    ["weapon_thrown_bolas"] = {
        name = 'Standard Bolas',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "perfect_bear_pelt", amount = 1 },
            [2] = { item = "ironore", amount = 1 }
        },
        receive = "weapon_thrown_bolas"
    },
    ["weapon_thrown_bolas_hawkmoth"] = {
        name = 'Hawkmoth Bolas',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "perfect_bear_pelt", amount = 1 },
            [2] = { item = "ironore", amount = 1 }
        },
        receive = "weapon_thrown_bolas_hawkmoth"
    },
    ["weapon_thrown_bolas_ironspiked"] = {
        name = 'Ironspiked Bolas',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "perfect_bear_pelt", amount = 1 },
            [2] = { item = "ironore", amount = 1 }
        },
        receive = "weapon_thrown_bolas_ironspiked"
    },
    ["weapon_thrown_bolas_intertwined"] = {
        name = 'Intertwined Bolas',
        crafttime = 5000,
        category = "Thrown Weapons",
        ingredients = {
            [1] = { item = "perfect_bear_pelt", amount = 1 },
            [2] = { item = "ironore", amount = 1 }
        },
        receive = "weapon_thrown_bolas_intertwined"
    },
    ["weapon_thrown_dynamite"] = {
        name = 'Throwable Dynamite',
        crafttime = 10000,
        category = "Explosives",
        ingredients = {
            [1] = { item = "tnt", amount = 1 },
            [2] = { item = "wood", amount = 1 }
        },
        receive = "weapon_thrown_dynamite"
    },
    ["weapon_thrown_molotov"] = {
        name = 'Molotov',
        crafttime = 5000,
        category = "Explosives",
        ingredients = {
            [1] = { item = "oilcan", amount = 1 },
            [2] = { item = "gunpowder", amount = 1 }
        },
        receive = "weapon_thrown_molotov"
    },
    ["weapon_thrown_poisonbottle"] = {
        name = 'Poison Bottle',
        crafttime = 5000,
        category = "Explosives",
        ingredients = {
            [1] = { item = "morphine", amount = 1 },
            [2] = { item = "oilcan", amount = 1 }
        },
        receive = "weapon_thrown_poisonbottle"
    }
}
