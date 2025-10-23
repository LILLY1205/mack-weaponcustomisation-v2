Config = Config or {}

-- Materials required to apply customisation per category.
-- You can override per-weapon by adding Config.CustomMaterials.perWeapon[weaponName][CATEGORY]
Config.CustomMaterials = {
  default = {
    -- Core fitment categories
    GRIP = { { item = 'wood', amount = 2 } },
    SIGHT = { { item = 'ironore', amount = 1 } },
    BARREL = { { item = 'iron_bar', amount = 1 } },
    WRAP = { { item = 'wood', amount = 1 } },
    STOCK = { { item = 'wood', amount = 2 } },
    CLIP = { { item = 'steel', amount = 1 } },
    TUBE = { { item = 'steel', amount = 1 } },
    MAG = { { item = 'steel', amount = 1 } },
    SCOPE = { { item = 'steel', amount = 2 } },

    -- Materials categories
    TRIGGER_MATERIAL = { { item = 'steel', amount = 1 } },
    SIGHT_MATERIAL = { { item = 'ironore', amount = 1 } },
    HAMMER_MATERIAL = { { item = 'steel', amount = 1 } },
    FRAME_MATERIAL = { { item = 'steel', amount = 1 } },
    FRAME_ENGRAVING = { { item = 'steel', amount = 1 } },
    FRAME_ENGRAVING_MATERIAL = { { item = 'steel', amount = 1 } },
    BARREL_MATERIAL = { { item = 'iron_bar', amount = 1 } },
    BARREL_ENGRAVING = { { item = 'steel', amount = 1 } },
    BARREL_ENGRAVING_MATERIAL = { { item = 'steel', amount = 1 } },
    CYLINDER_MATERIAL = { { item = 'iron_bar', amount = 1 } },
    CYLINDER_ENGRAVING = { { item = 'steel', amount = 1 } },
    CYLINDER_ENGRAVING_MATERIAL = { { item = 'steel', amount = 1 } },
    GRIP_MATERIAL = { { item = 'wood', amount = 2 } },
    GRIPSTOCK_ENGRAVING = { { item = 'steel', amount = 1 } },
    WRAP_MATERIAL = { { item = 'wood', amount = 1 } },

    -- Tints / oils and finishing
    CYLINDER_TINT = { { item = 'oilcan', amount = 1 } },
    BARREL_TINT   = { { item = 'oilcan', amount = 1 } },
    TRIGGER_TINT  = { { item = 'oilcan', amount = 1 } },
    GRIP_TINT     = { { item = 'oilcan', amount = 1 } },
    GRIPSTOCK_TINT= { { item = 'oilcan', amount = 1 } },
    WRAP_TINT     = { { item = 'oilcan', amount = 1 } },

    -- Misc
    BARREL_RIFLING = { { item = 'iron_bar', amount = 1 } },
    TORCH_MATCHSTICK = { { item = 'wood', amount = 1 } },
  },
  perWeapon = {
    -- Example override:
    -- ['WEAPON_REVOLVER_CATTLEMAN'] = { GRIP = { { item = 'wood', amount = 3 } } }
  }
}
