local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local DEBUG = "|cffff0000Debug:|r "

function addon:GuessName(name)
    local list = self.db.profile.list

    if not list[name] then
        return name
    end

    local i
    for i = 2, 99 do
        local try = string.format("%s (%d)", name, i)
        if not list[try] then
            return try
        end
    end
end

function addon:SaveProfile(name, options)
    local list = self.db.profile.list
    local profile = { name = name }

    self:UpdateProfileOptions(profile, options, true)
    self:UpdateProfile(profile, true)

    list[name] = profile

    self:UpdateGUI()
    self:Printf(L.msg_profile_saved, name)
end

function addon:UpdateProfileOptions(profile, options, quiet)
    if type(profile) ~= "table" then
        local list = self.db.profile.list
        profile = list[profile]

        if not profile then return end
    end

    if options then
        local k, v
        for k in pairs(profile) do
            if k:sub(1, 4) == "skip" then
                profile[k] = nil
            end
        end

        for k, v in pairs(options) do
            profile[k] = v
        end
    end

    if not quiet then
        self:UpdateGUI()
        self:Printf(L.msg_profile_updated, profile.name)
    end
end

function addon:UpdateProfile(profile, quiet)
    if type(profile) ~= "table" then
        local list = self.db.profile.list
        profile = list[profile]

        if not profile then return end
    end

    profile.class = select(2, UnitClass("player"))
    profile.icon  = select(4, GetSpecializationInfo(GetSpecialization()))

    self:SaveActions(profile)
    self:SavePetActions(profile)
    self:SaveBindings(profile)

    if not quiet then
        self:UpdateGUI()
        self:Printf(L.msg_profile_updated, profile.name)
    end

    return profile
end

function addon:RenameProfile(name, rename, quiet)
    local list = self.db.profile.list
    local profile = list[name]

    if not profile then return end

    profile.name = rename

    list[name] = nil
    list[rename] = profile

    if not quiet then
        self:UpdateGUI()
    end

    self:Printf(L.msg_profile_renamed, name, rename)
end

function addon:DeleteProfile(name)
    local list = self.db.profile.list

    list[name] = nil

    self:UpdateGUI()
    self:Printf(L.msg_profile_deleted, name)
end

function addon:SaveActions(profile)
    local flyouts, tsNames, tsIds = {}, {}, {}

    local book
    for book = 1, GetNumSpellTabs() do
        local offset, count, _, spec = select(3, GetSpellTabInfo(book))

        if spec == 0 then
            local index
            for index = offset + 1, offset + count do
                local type, id = GetSpellBookItemInfo(index, BOOKTYPE_SPELL)
                local name = GetSpellBookItemName(index, BOOKTYPE_SPELL)

                if type == "FLYOUT" then
                    flyouts[id] = name

                elseif type == "SPELL" and IsTalentSpell(index, BOOKTYPE_SPELL) then
                    tsNames[name] = id
                end
            end
        end
    end

    local talents = {}

    local tier
    for tier = 1, MAX_TALENT_TIERS do
        local column = select(2, GetTalentTierInfo(tier, 1))
        if column and column > 0 then
            local id, name = GetTalentInfo(tier, column, 1)

            if tsNames[name] then
                tsIds[tsNames[name]] = id
            end

            talents[tier] = GetTalentLink(id)
        end
    end

    profile.talents = talents

    local actions = {}
    local savedMacros = {}

    local slot
    for slot = 1, ABP_MAX_ACTION_BUTTONS do
        local type, id, sub = GetActionInfo(slot)

        if type == "spell" then
            if tsIds[id] then
                actions[slot] = GetTalentLink(tsIds[id])
            else
                actions[slot] = GetSpellLink(id)
            end

        elseif type == "flyout" then
            if flyouts[id] then
                actions[slot] = string.format(
                    "|cffff0000|Habp:flyout:%d|h[%s]|h|r",
                    id, flyouts[id]
                )
            end

        elseif type == "item" then
            actions[slot] = select(2, GetItemInfo(id))

        elseif type == "companion" then
            if sub == "MOUNT" then
                actions[slot] = GetSpellLink(id)
            end

        elseif type == "summonpet" then
            actions[slot] = C_PetJournal.GetBattlePetLink(id)

        elseif type == "summonmount" then
            if id == 0xFFFFFFF then
                actions[slot] = GetSpellLink(ABP_RANDOM_MOUNT_SPELL_ID)
            else
                actions[slot] = GetSpellLink(({ C_MountJournal.GetMountInfoByID(id) })[2])
            end

        elseif type == "macro" then
            if id > 0 then
                local name, icon, body = GetMacroInfo(id)

                icon = icon or ABP_EMPTY_ICON_TEXTURE_ID

                if id > MAX_ACCOUNT_MACROS then
                    actions[slot] = string.format(
                        "|cffff0000|Habp:macro:%s:%s|h[%s]|h|r",
                        icon, self:EncodeLink(body), name
                    )
                else
                    actions[slot] = string.format(
                        "|cffff0000|Habp:macro:%s:%s:1|h[%s]|h|r",
                        icon, self:EncodeLink(body), name
                    )
                end

                savedMacros[id] = true
            end

        elseif type == "equipmentset" then
            actions[slot] = string.format(
                "|cffff0000|Habp:equip|h[%s]|h|r",
                id
            )
        end
    end

    profile.actions = actions

    local macros = {}
    local allMacros, charMacros = GetNumMacros()

    local index
    for index = 1, allMacros do
        local name, icon, body = GetMacroInfo(index)

        icon = icon or ABP_EMPTY_ICON_TEXTURE_ID

        if body and not savedMacros[index] then
            table.insert(macros, string.format(
                "|cffff0000|Habp:macro:%s:%s:1|h[%s]|h|r",
                icon, self:EncodeLink(body), name
            ))
        end
    end

    for index = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + charMacros do
        local name, icon, body = GetMacroInfo(index)

        icon = icon or ABP_EMPTY_ICON_TEXTURE_ID

        if body and not savedMacros[index] then
            table.insert(macros, string.format(
                "|cffff0000|Habp:macro:%s:%s|h[%s]|h|r",
                icon, self:EncodeLink(body), name
            ))
        end
    end

    profile.macros = macros
end

function addon:SavePetActions(profile)
    local petActions = nil

    if HasPetSpells() then
        local petSpells = {}

        local index
        for index = 1, HasPetSpells() do
            local id = select(2, GetSpellBookItemInfo(index, BOOKTYPE_PET))

            if id then
                local name = GetSpellBookItemName(index, BOOKTYPE_PET)
                petSpells[name] = id
            end
        end

        petActions = {}

        local slot
        for slot = 1, NUM_PET_ACTION_SLOTS do
            local name, _, _, token = GetPetActionInfo(slot)

            if name then
                if token then
                    petActions[slot] = string.format(
                        "|cffff0000|Habp:pet:%s|h[%s]|h|r",
                        name, _G[name]
                    )
                else
                    petActions[slot] = GetSpellLink(petSpells[name])
                end
            end
        end
    end

    profile.petActions = petActions
end

function addon:SaveBindings(profile)
    local bindings = {}

    local index
    for index = 1, GetNumBindings() do
        local bind = { GetBinding(index) }
        if bind[3] then
            bindings[bind[1]] = { select(3, unpack(bind)) }
        end
    end

    profile.bindings = bindings

    local bindingsDominos = nil

    if LibStub("AceAddon-3.0"):GetAddon("Dominos", true) then
        bindingsDominos = {}

        for index = 13, 60 do
            local bind = { GetBindingKey(string.format("CLICK DominosActionButton%d:LeftButton", index)) }
            if #bind > 0 then
                bindingsDominos[index] = bind
            end
        end
    end

    profile.bindingsDominos = bindingsDominos
end

function addon:ResetDefault(key, quiet)
    local list = self.db.profile.list
    local profile

    for profile in table.s2k_values(list) do
        profile.fav = profile.fav or {}
        profile.fav[key] = nil
    end

    if not quiet then
        self:UpdateGUI()
    end
end

function addon:SetDefault(name, key)
    local list = self.db.profile.list
    local profile = list[name]

    if not profile then return end

    self:ResetDefault(key, true)

    profile.fav = profile.fav or {}
    profile.fav[key] = 1

    self:UpdateGUI()
end

function addon:UnsetDefault(name, key)
    local list = self.db.profile.list
    local profile = list[name]

    if not profile then return end

    profile.fav = profile.fav or {}
    profile.fav[key] = nil

    self:UpdateGUI()
end
