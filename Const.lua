ABP_MAX_ACTION_BUTTONS = 120
ABP_DEFAULT_PAPERDOLL_NUM_TABS = 3

ABP_PICKUP_RETRY_COUNT = 5
ABP_PICKUP_RETRY_INTERVAL = 0.3

ABP_RANDOM_MOUNT_SPELL_ID = 150544

ABP_SIMILAR_ITEMS = {
    [6948]   = { 64488 },           -- Hearthstone
    [64488]  = { 6948 },            -- The Innkeeper's Daughter
    [118922] = { 86569, 75525 },    -- Oralius' Whispering Crystal
    [86569]  = { 118922, 75525 },   -- Crystal of Insanity
    [75525]  = { 118922, 86569 },   -- Alchemist's Flask
}

ABP_SIMILAR_SPELLS = {
    -- mage portals
    [10059]  = { 11417 },   -- Portal: Stormwind
    [11416]  = { 11418 },   -- Portal: Ironforge
    [11419]  = { 11420 },   -- Portal: Darnassus
    [32266]  = { 32267 },   -- Portal: Exodar
    [49360]  = { 49361 },   -- Portal: Theramore
    [33691]  = { 35717 },   -- Portal: Shattrath
    [88345]  = { 88346 },   -- Portal: Tol Barad
    [132620] = { 132626 },  -- Portal: Vale of Eternal Blossoms
    [176246] = { 176244 },  -- Portal: Stormshield
    [11417]  = { 10059 },   -- Portal: Orgrimmar
    [11418]  = { 11416 },   -- Portal: Undercity
    [11420]  = { 11419 },   -- Portal: Thunder Bluff
    [32267]  = { 32266 },   -- Portal: Silvermoon
    [49361]  = { 49360 },   -- Portal: Stonard
    [35717]  = { 33691 },   -- Portal: Shattrath
    [88346]  = { 88345 },   -- Portal: Tol Barad
    [132626] = { 132620 },  -- Portal: Vale of Eternal Blossoms
    [176244] = { 176246 },  -- Portal: Warspear

    -- mage teleports
    [3561]   = { 3567 },    -- Teleport: Stormwind
    [3562]   = { 3563 },    -- Teleport: Ironforge
    [3565]   = { 3566 },    -- Teleport: Darnassus
    [32271]  = { 32272 },   -- Teleport: Exodar
    [49359]  = { 49358 },   -- Teleport: Theramore
    [33690]  = { 35715 },   -- Teleport: Shattrath
    [88342]  = { 88344 },   -- Teleport: Tol Barad
    [132621] = { 132627 },  -- Teleport: Vale of Eternal Blossoms
    [176248] = { 176242 },  -- Teleport: Stormshield
    [3567]   = { 3561 },    -- Teleport: Orgrimmar
    [3563]   = { 3562 },    -- Teleport: Undercity
    [3566]   = { 3565 },    -- Teleport: Thunder Bluff
    [32272]  = { 32271 },   -- Teleport: Silvermoon
    [49358]  = { 49359 },   -- Teleport: Stonard
    [35715]  = { 33690 },   -- Teleport: Shattrath
    [88344]  = { 88342 },   -- Teleport: Tol Barad
    [132627] = { 132621 },  -- Teleport: Vale of Eternal Blossoms
    [176242] = { 176248 },  -- Teleport: Warspear
}

ABP_SPECIAL_SPELLS = {
    -- draenor zone ability
    [161691] = {
        level = 90,
        altSpellIds = { 161676, 161332, 162075, 161767, 170097, 170108, 168487, 168499, 164012, 164050, 165803, 164222, 160240, 160241 },
    },

    -- hunter pets
    [883]    = { class = "HUNTER" },                    -- Call Pet 1
    [83242]  = { class = "HUNTER", level = 10 },        -- Call Pet 2
    [83243]  = { class = "HUNTER", level = 34 },        -- Call Pet 3
    [83244]  = { class = "HUNTER", level = 62 },        -- Call Pet 4
    [83245]  = { class = "HUNTER", level = 82 },        -- Call Pet 5
    [1462]   = { class = "HUNTER", level = 12 },        -- Beast Lore
    [2641]   = { class = "HUNTER", level = 10 },        -- Dismiss Pet
    [6991]   = { class = "HUNTER", level = 11 },        -- Feed Pet
    [982]    = { class = "HUNTER" },                    -- Revive Pet
    [1515]   = { class = "HUNTER", level = 10 },        -- Tame Beast

    -- warlock daemons
    [688]    = { class = "WARLOCK" },                   -- Summon Imp
    [697]    = { class = "WARLOCK", level = 8 },        -- Summon Voidwalker
    [712]    = { class = "WARLOCK", level = 28 },       -- Summon Succubus
    [691]    = { class = "WARLOCK", level = 35 },       -- Summon FelHUNTER
    [30146]  = { class = "WARLOCK", level = 40 },       -- Summon Felguard

    -- mage portals
    [53142]  = { class = "MAGE", level = 74 },                          -- Portal: Dalaran - Northrend
    [224871] = { class = "MAGE", level = 74 },                          -- Portal: Dalaran - Broken Isles
    [120146] = { class = "MAGE", level = 74 },                          -- Ancient Portal: Dalaran
    [10059]  = { class = "MAGE", level = 42, faction = "Alliance" },    -- Portal: Stormwind
    [11416]  = { class = "MAGE", level = 42, faction = "Alliance" },    -- Portal: Ironforge
    [11419]  = { class = "MAGE", level = 42, faction = "Alliance" },    -- Portal: Darnassus
    [32266]  = { class = "MAGE", level = 42, faction = "Alliance" },    -- Portal: Exodar
    [49360]  = { class = "MAGE", level = 42, faction = "Alliance" },    -- Portal: Theramore
    [33691]  = { class = "MAGE", level = 66, faction = "Alliance" },    -- Portal: Shattrath
    [88345]  = { class = "MAGE", level = 85, faction = "Alliance" },    -- Portal: Tol Barad
    [132620] = { class = "MAGE", level = 90, faction = "Alliance" },    -- Portal: Vale of Eternal Blossoms
    [176246] = { class = "MAGE", level = 92, faction = "Alliance" },    -- Portal: Stormshield
    [11417]  = { class = "MAGE", level = 42, faction = "Horde" },       -- Portal: Orgrimmar
    [11418]  = { class = "MAGE", level = 42, faction = "Horde" },       -- Portal: Undercity
    [11420]  = { class = "MAGE", level = 42, faction = "Horde" },       -- Portal: Thunder Bluff
    [32267]  = { class = "MAGE", level = 42, faction = "Horde" },       -- Portal: Silvermoon
    [49361]  = { class = "MAGE", level = 52, faction = "Horde" },       -- Portal: Stonard
    [35717]  = { class = "MAGE", level = 66, faction = "Horde" },       -- Portal: Shattrath
    [88346]  = { class = "MAGE", level = 85, faction = "Horde" },       -- Portal: Tol Barad
    [132626] = { class = "MAGE", level = 90, faction = "Horde" },       -- Portal: Vale of Eternal Blossoms
    [176244] = { class = "MAGE", level = 92, faction = "Horde" },       -- Portal: Warspear

    -- mage teleports
    [193759] = { class = "MAGE", level = 14 },                          -- Teleport: Hall of the Guardian
    [53140]  = { class = "MAGE", level = 71 },                          -- Teleport: Dalaran - Northrend
    [224869] = { class = "MAGE", level = 71 },                          -- Teleport: Dalaran - Broken Isles
    [120145] = { class = "MAGE", level = 71 },                          -- Ancient Teleport: Dalaran
    [3561]   = { class = "MAGE", level = 17, faction = "Alliance" },    -- Teleport: Stormwind
    [3562]   = { class = "MAGE", level = 17, faction = "Alliance" },    -- Teleport: Ironforge
    [3565]   = { class = "MAGE", level = 17, faction = "Alliance" },    -- Teleport: Darnassus
    [32271]  = { class = "MAGE", level = 17, faction = "Alliance" },    -- Teleport: Exodar
    [49359]  = { class = "MAGE", level = 17, faction = "Alliance" },    -- Teleport: Theramore
    [33690]  = { class = "MAGE", level = 62, faction = "Alliance" },    -- Teleport: Shattrath
    [88342]  = { class = "MAGE", level = 85, faction = "Alliance" },    -- Teleport: Tol Barad
    [132621] = { class = "MAGE", level = 90, faction = "Alliance" },    -- Teleport: Vale of Eternal Blossoms
    [176248] = { class = "MAGE", level = 92, faction = "Alliance" },    -- Teleport: Stormshield
    [3567]   = { class = "MAGE", level = 17, faction = "Horde" },       -- Teleport: Orgrimmar
    [3563]   = { class = "MAGE", level = 17, faction = "Horde" },       -- Teleport: Undercity
    [3566]   = { class = "MAGE", level = 17, faction = "Horde" },       -- Teleport: Thunder Bluff
    [32272]  = { class = "MAGE", level = 17, faction = "Horde" },       -- Teleport: Silvermoon
    [49358]  = { class = "MAGE", level = 52, faction = "Horde" },       -- Teleport: Stonard
    [35715]  = { class = "MAGE", level = 62, faction = "Horde" },       -- Teleport: Shattrath
    [88344]  = { class = "MAGE", level = 85, faction = "Horde" },       -- Teleport: Tol Barad
    [132627] = { class = "MAGE", level = 90, faction = "Horde" },       -- Teleport: Vale of Eternal Blossoms
    [176242] = { class = "MAGE", level = 92, faction = "Horde" },       -- Teleport: Warspear

    -- rogue poisons
    [2823]   = { class = "ROGUE", spec = 259, level = 2 },              -- Deadly Poison
    [3408]   = { class = "ROGUE", spec = 259, level = 19 },             -- Crippling Poison
    [8679]   = { class = "ROGUE", spec = 259, level = 25 },             -- Wound Poison
    [108211] = { class = "ROGUE", spec = 259, level = 60 },             -- Leeching Poison
    [200802] = { class = "ROGUE", spec = 259, level = 90 },             -- Agonizing Poison
}
