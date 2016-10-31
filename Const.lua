ABP_DB_VERSION = "v3"

ABP_COMM_PREFIX = "ABP" .. ABP_DB_VERSION

ABP_COMM_CMD = ABP_COMM_PREFIX .. "cmd"
ABP_COMM_SHARE = ABP_COMM_PREFIX .. "share"

ABP_ADDON_NAME = "Action Bar Profiles"
ABP_DOWNLOAD_LINK = "https://mods.curse.com/addons/wow/action-bar-profiles"

ABP_MAX_ACTION_BUTTONS = 120
ABP_DEFAULT_PAPERDOLL_NUM_TABS = 3

ABP_PICKUP_RETRY_COUNT = 5
ABP_PICKUP_RETRY_INTERVAL = 0.1

ABP_EMPTY_ICON_TEXTURE_ID = 134400
ABP_RANDOM_MOUNT_SPELL_ID = 150544

ABP_TOME_OF_CLEAR_MIND_SPELL_ID = 227563
ABP_TOME_OF_TRANQUIL_MIND_SPELL_ID = 227041
ABP_DUNGEON_PREPARE_SPELL_ID = 228128

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

    -- primary racial trait
    [68992]  = { 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Darkflight
    [20589]  = { 68992, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Escape Artist
    [20594]  = { 68992, 20589, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Stoneform
    [28880]  = { 68992, 20589, 20594, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [59542]  = { 68992, 20589, 20594, 28880, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [59543]  = { 68992, 20589, 20594, 28880, 59542, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [59544]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [59545]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [59547]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [59548]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Gift of the Naaru
    [121093] = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },   -- Gift of the Naaru
    [58984]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Shadowmeld
    [59752]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Every Man for Himself
    [69041]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Rocket Barrage
    [7744]   = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 }, -- Will of the Forsaken
    [20572]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Blood Fury
    [33697]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Blood Fury
    [33702]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Blood Fury
    [20549]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- War Stomp
    [26297]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 25046, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Berserking
    [25046]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 28730, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Arcane Torrent
    [28730]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 50613, 69179, 80483, 129597, 155145, 202719 },  -- Arcane Torrent
    [50613]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 69179, 80483, 129597, 155145, 202719 },  -- Arcane Torrent
    [69179]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 80483, 129597, 155145, 202719 },  -- Arcane Torrent
    [80483]  = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 129597, 155145, 202719 },  -- Arcane Torrent
    [129597] = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 155145, 202719 },   -- Arcane Torrent
    [155145] = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 202719 },   -- Arcane Torrent
    [202719] = { 68992, 20589, 20594, 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093, 58984, 59752, 69041, 7744, 20572, 33697, 33702, 20549, 26297, 25046, 28730, 50613, 69179, 80483, 129597, 155145 },   -- Arcane Torrent

    -- secondary racial trait
    [87840]  = { 69070, 20577 },    -- Running Wild
    [69070]  = { 87840, 20577 },    -- Rocket Jump
    [20577]  = { 87840, 69070 },    -- Cannibalize
}

ABP_SPECIAL_SPELLS = {
    -- draenor zone ability
    [161691] = {
        level = 90,
        altSpellIds = { 161676, 161332, 162075, 161767, 170097, 170108, 168487, 168499, 164012, 164050, 165803, 164222, 160240, 160241 },
    },
    -- broken isles combat ally ability
    [211390] = {
        level = 100,
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
    [136]    = { class = "HUNTER" },                    -- Mend Pet
    [982]    = { class = "HUNTER" },                    -- Revive Pet
    [1515]   = { class = "HUNTER", level = 10 },        -- Tame Beast

    -- hunter traps
    [187650] = { class = "HUNTER", spec = 255, level = 16 },        -- Freezing Trap
    [187698] = { class = "HUNTER", spec = 255, level = 36 },        -- Tar Trap
    [191433] = { class = "HUNTER", spec = 255, level = 50 },        -- Explosive Trap

    -- warlock daemons
    [688]    = { class = "WARLOCK" },                   -- Summon Imp
    [697]    = { class = "WARLOCK", level = 8 },        -- Summon Voidwalker
    [712]    = { class = "WARLOCK", level = 28 },       -- Summon Succubus
    [691]    = { class = "WARLOCK", level = 35 },       -- Summon Felhunter
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

    -- paladin blessings
    [203528] = { class = "PALADIN", spec = 70, level = 42 },            -- Greater Blessing of Might
    [203538] = { class = "PALADIN", spec = 70, level = 44 },            -- Greater Blessing of Kings
    [203539] = { class = "PALADIN", spec = 70, level = 46 },            -- Greater Blessing of Wisdom
}
