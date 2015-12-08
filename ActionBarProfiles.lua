local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceConsole-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local S2KMounts = LibStub("LibS2kMounts-1.0")
local S2KFI = LibStub("LibS2kFactionalItems-1.0")

local MAX_ACTION_BUTTONS = 120
local PET_JOURNAL_FLAGS = { LE_PET_JOURNAL_FLAG_COLLECTED, LE_PET_JOURNAL_FLAG_NOT_COLLECTED }

local DEFAULT_PAPERDOLL_NUM_TABS = 3

local SIMILAR_ITEMS = {
    [6948]   = { 64488 },   -- Hearthstone
    [64488]  = { 6948 },    -- The Innkeeper's Daughter
    [118922] = { 86569, 75525 },    -- Oralius' Whispering Crystal
    [86569]  = { 118922, 75525 },   -- Crystal of Insanity
    [75525]  = { 118922, 86569 },   -- Alchemist's Flask
}

local SIMILAR_SPELLS = {
    [152280] = { 43265 },   -- Defile
    [108194] = { 47476 },   -- Asphyxiate
}

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    }, true)

    self:InjectPaperDollSidebarTab(
        L.charframe_tab,
        "PaperDollActionBarProfilesPane",
        "Interface\\AddOns\\ActionBarProfiles\\textures\\CharDollBtn",
        { 0, 0.515625, 0, 0.13671875 }
    )

    self.ldb = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
        type = 'launcher',
        --icon = 'Interface\\AddOns\\ActionBarProfiles\\textures\\CharDollBtnIcon',
        icon = 'Interface\\ICONS\\INV_Misc_Book_09',
        label = "Action Bar Profiles",
        OnEnter = function(...)
        end,
        OnLeave = function()
        end,
        OnClick = function(obj, button)
            if button == 'RightButton' then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            else
            end
        end,
    })

    self.icon = LibStub('LibDBIcon-1.0')
    self.icon:Register(addonName, self.ldb, self.db.profile.minimap)

    self:RegisterChatCommand("abp", "OnChatCommand")

    LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, self:GetOptions())
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName, addonName, nil)

    PaperDollActionBarProfilesPane:OnInitialize()
    PaperDollActionBarProfilesSaveDialog:OnInitialize()
end

function addon:OnChatCommand(message)
    local cmd, pos = self:GetArgs(message, 1, 1)
    local param = message:sub(pos)

    if cmd then
        if cmd == "use" then
            param = strtrim(param or "")

            if param ~= "" then
                local profile = self:GetProfile(strtrim(param), true)

                if profile then
                    self:UseProfile(profile.name)
                end
            end
        elseif cmd == "save" then
            param = strtrim(param or "")

            if param ~= "" then
                local profile = self:GetProfile(strtrim(param), true)

                if profile then
                    self:UpdateProfileBars(profile.name)
                else
                    self:SaveProfile(param, {})
                end

                PaperDollActionBarProfilesPane:Update()
            end
        elseif cmd == "delete" or cmd == "del" then
            param = strtrim(param or "")

            if param ~= "" then
                local profile = self:GetProfile(strtrim(param), true)

                if profile then
                    self:DeleteProfile(profile.name)
                    PaperDollActionBarProfilesPane:Update()
                end
            end
        elseif cmd == "list" then
            local profilesByClass = {}

            local profile
            for profile in table.s2k_values(self:GetSortedProfiles()) do
                profilesByClass[profile.class] = profilesByClass[profile.class] or {}

                table.insert(profilesByClass[profile.class], profile.name)
            end

            local locClasses = {}
            FillLocalizedClassList(locClasses)
            table.sort(locClasses)

            for class, locClass in pairs(locClasses) do
                if profilesByClass[class] then
                    self:Printf("%s: %s", locClass, strjoin(", ", unpack(profilesByClass[class])))
                end
            end
        end
    end
end

function addon:GetSimilarItems(itemId)
    local ret = SIMILAR_ITEMS[itemId]
    if ret then
        return unpack(ret)
    end
end

function addon:GetSimilarSpells(spellId)
    local ret = SIMILAR_SPELLS[spellId]
    if ret then
        return unpack(ret)
    end
end

function addon:GetSortedProfiles()
    local profiles = self.db.global.profiles or {}
    local sorted = {}

    local k, v
    for k, v in pairs(profiles) do
        v.name = k
        table.insert(sorted, v)
    end

    local playerClass = select(2, UnitClass("player"))

    table.sort(sorted, function(a, b)
        if a.class == b.class then
            return a.name < b.name
        else
            return a.class == playerClass
        end
    end)

    return sorted
end

function addon:GetProfile(name, ignoreCase)
    local profile
    for profile in table.s2k_values(self:GetSortedProfiles()) do
        if profile.name == name or (ignoreCase and profile.name:lower() == name:lower()) then
            return profile
        end
    end
end

function addon:UseProfile(name, checkOnly, cache)
    local profiles = self.db.global.profiles or {}
    local profile = profiles[name]

    if not cache then
        cache = self:MakeCache()
    end

    local fail, total = 0, 0

    if profile then
        local slot
        for slot = 1, MAX_ACTION_BUTTONS do
            local ok

            if profile.actions[slot] then
                local type, id, subType, extraId = unpack(profile.actions[slot])

                if type == "spell" then
                    if not profile.skip_spells then
                        ok = self:RestoreSpell(cache, profile, slot, checkOnly)

                        total = total + 1
                        fail = fail + ((ok and 0) or 1)
                    end

                elseif type == "flyout" then
                    if not profile.skip_spells then
                        ok = self:RestoreFlyout(cache, profile, slot, checkOnly)

                        total = total + 1
                        fail = fail + ((ok and 0) or 1)
                    end

                elseif type == "item" then
                    if not profile.skip_items then
                        ok = self:RestoreItem(cache, profile, slot, checkOnly) or self:RestoreMissingItem(cache, profile, slot, checkOnly)

                        total = total + 1
                        fail = fail + ((ok and 0) or 1)
                    end

                elseif type == "companion" then
                    if not profile.skip_companions then
                        if subType == "MOUNT" then
                            ok = self:RestoreMount(cache, profile, slot, checkOnly)

                            total = total + 1
                            fail = fail + ((ok and 0) or 1)
                        end
                    end

                elseif type == "summonmount" then
                    if not profile.skip_companions then
                        ok = self:RestoreMount(cache, profile, slot, checkOnly)

                        total = total + 1
                        fail = fail + ((ok and 0) or 1)
                    end

                elseif type == "summonpet" then
                    if not profile.skip_companions then
                        ok = self:RestorePet(cache, profile, slot, checkOnly)

                        total = total + 1
                        fail = fail + ((ok and 0) or 1)
                    end

                elseif type == "macro" then
                    if id > 0 then
                        if not profile.skip_macros then
                            ok = self:RestoreMacro(cache, profile, slot, checkOnly)

                            total = total + 1
                            fail = fail + ((ok and 0) or 1)
                        end
                    end

                elseif type == "equipmentset" then
                    if not profile.skip_equip_sets then
                        ok = self:RestoreEquipSet(cache, profile, slot, checkOnly)

                        total = total + 1
                        fail = fail + ((ok and 0) or 1)
                    end
                end
            end

            if not ok and not profile.skip_empty_slots then
                self:ClearSlot(slot, checkOnly)
            end
        end

        if not profile.skip_pet_spells and HasPetSpells() and profile.petActions then
            for slot = 1, NUM_PET_ACTION_SLOTS do
                if not profile.skip_empty_slots then
                    self:ClearPetSlot(slot, checkOnly)
                end

                if profile.petActions[slot] then
                    total = total + 1
                    fail = fail + ((self:RestorePetSpell(cache, profile, slot, checkOnly) and 0) or 1)
                end
            end
        end

        if not (checkOnly or profile.skip_key_bindings) and profile.keyBindings then
            for i = 1, GetNumBindings() do
                local bind = { GetBinding(i) }
                if bind[3] then
                    local key
                    for key in table.s2k_values({ select(3, unpack(bind)) }) do
                        SetBinding(key)
                    end
                end
            end

            local cmd, keys
            for cmd, keys in pairs(profile.keyBindings) do
                local key
                for key in table.s2k_values(keys) do
                    SetBinding(key, cmd)
                end
            end

            SaveBindings(GetCurrentBindingSet())
        end
    end

    return fail, total
end

function addon:SaveProfile(name, options)
    local profiles = self.db.global.profiles or {}
    self.db.global.profiles = profiles

    profiles[name] = { name = name }

    self:UpdateProfileParams(name, nil, options)
    self:UpdateProfileBars(name)
end

function addon:UpdateProfileParams(name, rename, options)
    local profiles = self.db.global.profiles or {}
    local profile = profiles[name]

    if profile then
        if rename and name ~= rename then
            profiles[name] = nil
            profiles[rename] = profile

            profile.name = rename
        end

        local k, v
        for k in pairs(profile) do
            if k:sub(1, 5) == "skip_" then
                profile[k] = nil
            end
        end

        for k, v in pairs(options) do
            profile[k] = v
        end
    end
end

function addon:UpdateProfileBars(name)
    local profiles = self.db.global.profiles or {}
    local profile = profiles[name]

    if profile then
        profile.class = select(2, UnitClass("player"))
        profile.owner = string.format("%s-%s", GetUnitName("player"), GetRealmName())

        profile.actions = {}
        profile.petActions = nil

        local slot
        for slot = 1, MAX_ACTION_BUTTONS do
            local type, id, subType, extraId = GetActionInfo(slot)

            if type then
                if type == "item" then
                    profile.actions[slot] = { type, id, subType, extraId, ({ GetItemInfo(id) })[1] }

                elseif type == "macro" then
                    if id > 0 then
                        profile.actions[slot] = { type, id, subType, extraId, table.s2k_select({ GetMacroInfo(id) }, 1, 2) }
                    end

                elseif type == "summonpet" then
                    profile.actions[slot] = { type, id, subType, extraId, ({ C_PetJournal.GetPetInfoByPetID(id) })[11] }

                else
                    profile.actions[slot] = { type, id, subType, extraId }
                end
            end
        end

        if HasPetSpells() then
            profile.petActions = {}

            local petSpells = self:PreloadPetSpells()

            for slot = 1, NUM_PET_ACTION_SLOTS do
                local name, stance, icon, isToken = GetPetActionInfo(slot)
                if name then
                    if not isToken and not self:GetFromCache(petSpells, icon) then
                        local spellIndex = self:GetFromCache(petSpells, icon, name, stance)
                        if spellIndex then
                            icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE_PET)
                        end
                    end

                    profile.petActions[slot] = { name, stance, icon, isToken }
                end
            end
        end

        profile.keyBindings = {}

        local i
        for i = 1, GetNumBindings() do
            local bind = { GetBinding(i) }
            if bind[3] then
                profile.keyBindings[bind[1]] = { select(3, unpack(bind)) }
            end
        end
    end
end

function addon:DeleteProfile(name)
    local profiles = self.db.global.profiles or {}
    profiles[name] = nil
end

function addon:ClearSlot(slot, checkOnly)
    if not checkOnly then
        ClearCursor()
        PickupAction(slot)
        ClearCursor()
    end
end

function addon:PlaceToSlot(slot, checkOnly)
    if not checkOnly then
        PlaceAction(slot)
        ClearCursor()
    end
end

function addon:PlaceItemToSlot(slot, itemId, checkOnly)
    if not checkOnly then
        PickupItem(itemId)
        self:PlaceToSlot(slot)
    end
end

function addon:PlaceSpellToSlot(slot, spellId, checkOnly)
    if not checkOnly then
        PickupSpell(spellId)
        self:PlaceToSlot(slot)
    end
end

function addon:ClearPetSlot(slot, checkOnly)
    if not checkOnly then
        ClearCursor()
        PickupPetAction(slot)
        ClearCursor()
    end
end

function addon:PlaceToPetSlot(slot, checkOnly)
    if not checkOnly then
        PickupPetAction(slot)
        ClearCursor()
    end
end

function addon:UpdateCache(cache, value, id, name, stance)
    cache.id[id] = value

    if name then
        name = (stance and stance ~= "" and name .. "|" .. stance) or name
        cache.name[name] = value
    end
end

function addon:GetFromCache(cache, id, name, stance)
    if cache.id[id] then
        return cache.id[id]
    end

    if name then
        name = (stance and stance ~= "" and name .. "|" .. stance) or name
        if cache.name[name] then
            return cache.name[name]
        end
    end
end

function addon:MakeCache()
    local spells, flyouts = self:PreloadSpells()
    local items = self:PreloadItems()
    local mounts = self:PreloadMounts()
    local pets = self:PreloadPets()
    local macros = self:PreloadMacros()
    local petSpells = self:PreloadPetSpells()

    return { spells = spells, flyouts = flyouts, items = items, mounts = mounts,
        pets = pets, macros = macros, petSpells = petSpells }
end

function addon:PreloadSpells()
    local spells = { id = {}, name = {} }
    local flyouts = { id = {}, name = {} }

    local bookTabs = {}

    local bookIndex
    for bookIndex = 1, GetNumSpellTabs() do
        local bookOffset, numSpells, offSpecId = table.s2k_select({ GetSpellTabInfo(bookIndex) }, 3, 4, 6)

        if bookOffset and offSpecId == 0 then
            table.insert(bookTabs, { type = BOOKTYPE_SPELL, from = bookOffset + 1, to = bookOffset + numSpells })
        end
    end

    local profIndex
    for profIndex in table.s2k_values({ GetProfessions() }) do
        if profIndex then
            local bookOffset, numSpells = table.s2k_select({ GetProfessionInfo(profIndex) }, 6, 5)

            table.insert(bookTabs, { type = BOOKTYPE_PROFESSION, from = bookOffset + 1, to = bookOffset + numSpells })
        end
    end

    local bookTab
    for bookTab in table.s2k_values(bookTabs) do
        local spellIndex
        for spellIndex = bookTab.from, bookTab.to do
            local type, spellId = GetSpellBookItemInfo(spellIndex, bookTab.type)
            local name, stance = GetSpellBookItemName(spellIndex, bookTab.type)

            if type == "SPELL" then
                self:UpdateCache(spells, spellId, spellId, name, stance)

            elseif type == "FLYOUT" then
                self:UpdateCache(flyouts, spellIndex, spellId, name)
            end
        end
    end

    if UnitLevel("player") >= 90 then
        self:UpdateCache(spells, DraenorZoneAbilitySpellID, DraenorZoneAbilitySpellID)

        local spellId
        for spellId in pairs(DRAENOR_ZONE_SPELL_ABILITY_TEXTURES_BASE) do
            self:UpdateCache(spells, DraenorZoneAbilitySpellID, spellId)
        end
    end

    return spells, flyouts
end

function addon:PreloadItems()
    local items = { id = {}, name = {} }
    local levels = {}

    local slotIndex
    for slotIndex = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        local itemId = GetInventoryItemID("player", slotIndex)

        if itemId then
            local name, level = table.s2k_select({ GetItemInfo(itemId) }, 1, 4)

            if not levels[name] or level > levels[name] then
                self:UpdateCache(items, itemId, itemId, name)
                levels[name] = level
            else
                self:UpdateCache(items, itemId, itemId)
            end
        end
    end

    local bagIndex
    for bagIndex = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local itemIndex
        for itemIndex = 1, GetContainerNumSlots(bagIndex) do
            local itemId = GetContainerItemID(bagIndex, itemIndex)

            if itemId then
                local name, level = table.s2k_select({ GetItemInfo(itemId) }, 1, 4)

                if not levels[name] or level > levels[name] then
                    self:UpdateCache(items, itemId, itemId, name)
                    levels[name] = level
                else
                    self:UpdateCache(items, itemId, itemId)
                end
            end
        end
    end

    return items
end

function addon:PreloadMounts()
    local mounts = { id = {}, name = {} }

    local playerFaction = (UnitFactionGroup("player") == "Alliance" and 1) or 0

    local mountIndex
    for mountIndex = 1, C_MountJournal.GetNumMounts() do
        local name, spellId, faction, isCollected = table.s2k_select({ C_MountJournal.GetMountInfo(mountIndex) }, 1, 2, 9, 11)

        if isCollected and (not faction or faction == playerFaction) then
            self:UpdateCache(mounts, spellId, spellId, name)
        end
    end

    return mounts
end

function addon:PreloadPets()
    local pets = { id = {} }

    local saved = self:SavePetJournalFilters()

    C_PetJournal.ClearSearchFilter()

    C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true)
    C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, false)

    C_PetJournal.AddAllPetSourcesFilter()
    C_PetJournal.AddAllPetTypesFilter()

    local petIndex
    for petIndex = 1, C_PetJournal:GetNumPets() do
        local petId, creatureId = table.s2k_select({ C_PetJournal.GetPetInfoByIndex(petIndex) }, 1, 11)
        self:UpdateCache(pets, petId, creatureId)
    end

    self:RestorePetJournalFilters(saved)

    return pets
end

function addon:PreloadMacros()
    local macros = { id = {}, name = {} } -- id - "name|icon", name - "name"

    local macroIndex
    for macroIndex = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local name, icon = GetMacroInfo(macroIndex)

        if name and name ~= "" and icon then
            self:UpdateCache(macros, macroIndex, name .. "|" .. icon, name)
        end
    end

    return macros
end

function addon:PreloadPetSpells()
    local petSpells = { id = {}, name = {} } -- id - "icon"

    local numSpells = HasPetSpells()
    if numSpells then
        local spellIndex
        for spellIndex = 1, numSpells do
            local name, stance = GetSpellBookItemName(spellIndex, BOOKTYPE_PET)
            local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE_PET)

            self:UpdateCache(petSpells, spellIndex, icon, name, stance)
        end
    end

    return petSpells
end

function addon:RestoreSpell(cache, profile, slot, checkOnly)
    local id = profile.actions[slot][2]
    local name, stance = GetSpellInfo(id)

    local spellId = self:GetFromCache(cache.spells, id, name, stance)

    if spellId then
        self:PlaceSpellToSlot(slot, spellId, checkOnly)
        return true
    end

    for spellId in table.s2k_values({ self:GetSimilarSpells(id) }) do
        if cache.spells.id[spellId] then
            self:PlaceSpellToSlot(slot, spellId, checkOnly)
            return true
        end
    end
end

function addon:RestoreFlyout(cache, profile, slot, checkOnly)
    local id = profile.actions[slot][2]
    local name = GetFlyoutInfo(id)

    local flyoutIndex = self:GetFromCache(cache.flyouts, id, name)

    if flyoutIndex then
        if not checkOnly then
            PickupSpellBookItem(flyoutIndex, BOOKTYPE_SPELL)
            self:PlaceToSlot(slot)
        end
        return true
    end
end

function addon:RestoreItem(cache, profile, slot, checkOnly)
    local id = profile.actions[slot][2]
    local name = GetItemInfo(id) or profile.actions[slot][5]

    if PlayerHasToy(id) then
        self:PlaceItemToSlot(slot, id, checkOnly)
        return true
    end

    local itemId = self:GetFromCache(cache.items, id, name)

    if itemId then
        self:PlaceItemToSlot(slot, itemId, checkOnly)
        return true
    end

    local factItemId = S2KFI:GetConvertedItemId(id)

    if factItemId then
        local factItemName = GetItemInfo(factItemId)

        itemId = self:GetFromCache(cache.items, factItemId, factItemName)

        if itemId then
            self:PlaceItemToSlot(slot, itemId, checkOnly)
            return true
        end
    end

    for itemId in table.s2k_values({ self:GetSimilarItems(id) }) do
        if cache.items.id[itemId] then
            self:PlaceItemToSlot(slot, itemId, checkOnly)
            return true
        end
    end
end

function addon:RestoreMissingItem(cache, profile, slot, checkOnly)
    local id = profile.actions[slot][2]

    local itemId = S2KFI:GetConvertedItemId(id) or id

    if GetItemInfo(itemId) then
        self:PlaceItemToSlot(slot, itemId, checkOnly)
        return true
    end
end

function addon:RestoreMount(cache, profile, slot, checkOnly)
    local type, id = unpack(profile.actions[slot])

    if type == "summonmount" then
        if id == 0xFFFFFFF then
            if not checkOnly then
                C_MountJournal.Pickup(0)
                self:PlaceToSlot(slot)
            end
            return true
        end

        id = S2KMounts:GetSpellIdByMountId(id)
    end

    local name = GetSpellInfo(id)
    local spellId = self:GetFromCache(cache.mounts, id, name)

    if spellId then
        self:PlaceSpellToSlot(slot, spellId, checkOnly)
        return true
    end
end

function addon:RestorePet(cache, profile, slot, checkOnly)
    local id = profile.actions[slot][5]

    local petId = self:GetFromCache(cache.pets, id)

    if petId then
        if not checkOnly then
            C_PetJournal.PickupPet(petId)
            self:PlaceToSlot(slot)
        end
        return true
    end
end

function addon:RestoreMacro(cache, profile, slot, checkOnly)
    local name, icon = table.s2k_select(profile.actions[slot], 5, 6)

    local macroIndex = self:GetFromCache(cache.macros, name .. "|" .. icon, name)

    if macroIndex then
        if not checkOnly then
            PickupMacro(macroIndex)
            self:PlaceToSlot(slot)
        end
        return true
    end
end

function addon:RestoreEquipSet(cache, profile, slot, checkOnly)
    local name = profile.actions[slot][2]

    if GetEquipmentSetInfoByName(name) then
        if not checkOnly then
            PickupEquipmentSetByName(name)
            self:PlaceToSlot(slot)
        end
        return true
    end
end

function addon:RestorePetSpell(cache, profile, slot, checkOnly)
    local icon, isToken = table.s2k_select(profile.petActions[slot], 3, 4)

    icon = (isToken and _G[icon]) or icon

    local spellIndex = self:GetFromCache(cache.petSpells, icon)

    if spellIndex then
        if not checkOnly then
            PickupSpellBookItem(spellIndex, BOOKTYPE_PET)
            self:PlaceToPetSlot(slot)
        end
        return true
    end
end

function addon:SavePetJournalFilters()
    local saved = { flag = {}, source = {}, type = {} }

    saved.text = C_PetJournal.GetSearchFilter()

    local i
    for i in table.s2k_values(PET_JOURNAL_FLAGS) do
        saved.flag[i] = not C_PetJournal.IsFlagFiltered(i)
    end

    for i = 1, C_PetJournal.GetNumPetSources() do
        saved.source[i] = not C_PetJournal.IsPetSourceFiltered(i)
    end

    for i = 1, C_PetJournal.GetNumPetTypes() do
        saved.type[i] = not C_PetJournal.IsPetTypeFiltered(i)
    end

    return saved
end

function addon:RestorePetJournalFilters(saved)
    C_PetJournal.SetSearchFilter(saved.text)

    local i
    for i in table.s2k_values(PET_JOURNAL_FLAGS) do
        C_PetJournal.SetFlagFilter(i, saved.flag[i])
    end

    for i = 1, C_PetJournal.GetNumPetSources() do
        C_PetJournal.SetPetSourceFilter(i, saved.source[i])
    end

    for i = 1, C_PetJournal.GetNumPetTypes() do
        C_PetJournal.SetPetTypeFilter(i, saved.type[i])
    end
end

function addon:InjectPaperDollSidebarTab(name, frame, icon, texCoords)
    self:Fix3rdPartyAddons()

    local tabIndex = #PAPERDOLL_SIDEBARS + 1
    local extraTabs = tabIndex - DEFAULT_PAPERDOLL_NUM_TABS

    PAPERDOLL_SIDEBARS[tabIndex] = { name = name, frame = frame, icon = icon, texCoords = texCoords }

    CreateFrame(
        "Button", "PaperDollSidebarTab" .. tabIndex, PaperDollSidebarTabs,
        "PaperDollSidebarTabTemplate", tabIndex
    )

    self:LineUpPaperDollSidebarTabs()

    if not self.prevSetLevel then
        self.prevSetLevel = PaperDollFrame_SetLevel

        PaperDollFrame_SetLevel = function(...)
            self.prevSetLevel(...)

            local extraTabs = #PAPERDOLL_SIDEBARS - DEFAULT_PAPERDOLL_NUM_TABS

            if CharacterFrameInsetRight:IsVisible() then
                local i
                for i = 1, CharacterLevelText:GetNumPoints() do
                    point, relativeTo, relativePoint, xOffset, yOffset = CharacterLevelText:GetPoint(i)

                    if point == "CENTER" then
                        CharacterLevelText:SetPoint(
                            point, relativeTo, relativePoint,
                            xOffset - (20 + 10 * extraTabs), yOffset
                        )
                    end
                end
            end
        end
    end

    if not self.prevOnUpdate then
        self.prevOnUpdate = PaperDollSidebarTabs:GetScript("OnUpdate") or function() end

        PaperDollSidebarTabs:SetScript("OnUpdate", function(...)
            self.prevOnUpdate(...)
            self:Fix3rdPartyAddons()
        end)
    end
end

function addon:LineUpPaperDollSidebarTabs()
    local extraTabs = #PAPERDOLL_SIDEBARS - DEFAULT_PAPERDOLL_NUM_TABS

    local i, prevTab

    for i = 1, #PAPERDOLL_SIDEBARS do
        local tab = _G["PaperDollSidebarTab" .. i]
        if tab then
            tab:ClearAllPoints()
            tab:SetPoint("BOTTOMRIGHT", (extraTabs < 2 and -30) or (extraTabs < 3 and -10) or 0, 0)

            if prevTab then
                prevTab:ClearAllPoints()
                prevTab:SetPoint("RIGHT", tab, "LEFT", -4, 0)
            end

            prevTab = tab
        end
    end
end

function addon:Fix3rdPartyAddons()
    self:FixZygorGuideViewer()
end

function addon:FixZygorGuideViewer()
    if ZGVCharacterGearFinderButton and not self.fixedZGV then
        local i
        for i = 1, #PAPERDOLL_SIDEBARS do
            if PAPERDOLL_SIDEBARS[i].frame == "ZygorGearFinderFrame" then
                ZGVCharacterGearFinderButton:SetID(i)

                ZGVCharacterGearFinderButton.Icon:SetTexture(PAPERDOLL_SIDEBARS[i].icon)
                ZGVCharacterGearFinderButton.Icon:SetTexCoord(unpack(PAPERDOLL_SIDEBARS[i].texCoords))

                _G["PaperDollSidebarTab" .. i] = ZGVCharacterGearFinderButton
            end
        end

        self:LineUpPaperDollSidebarTabs()
        self.fixedZGV = true
    end
end
