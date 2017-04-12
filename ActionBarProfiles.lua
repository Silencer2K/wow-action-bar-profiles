local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local DEBUG = "|cffff0000Debug:|r "

local qtip = LibStub("LibQTip-1.0")

function addon:cPrintf(cond, ...)
    if cond then self:Printf(...) end
end

function addon:cPrint(cond, ...)
    if cond then self:Print(...) end
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB" .. ABP_DB_VERSION, {
        profile = {
            minimap = {
                hide = false,
            },
            list = {},
            replace_macros = false,
        },
    }, ({ UnitClass("player") })[2])

    self.db.RegisterCallback(self, "OnProfileReset", "UpdateGUI")
    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateGUI")
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateGUI")

    -- chat command
    self:RegisterChatCommand("abp", "OnChatCommand")

    -- settings page
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptions())

    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, nil, nil, "general")
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, self.options.args.profiles.name, addonName, "profiles")

    -- minimap icon
    self.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "launcher",
        icon = "Interface\\ICONS\\INV_Misc_Book_09",
        label = addonName,
        OnEnter = function(...)
            self:ShowTooltip(...)
        end,
        OnLeave = function()
        end,
        OnClick = function(obj, button)
            if button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            else
                ToggleCharacter("PaperDollFrame")
            end
        end,
    })

    self.icon = LibStub("LibDBIcon-1.0")
    self.icon:Register(addonName, self.ldb, self.db.profile.minimap)

    -- char frame
    if PaperDollActionBarProfilesPane then
        self:InjectPaperDollSidebarTab(
            L.charframe_tab,
            "PaperDollActionBarProfilesPane",
            "Interface\\AddOns\\ActionBarProfiles\\textures\\CharDollBtn",
            { 0, 0.515625, 0, 0.13671875 }
        )

        PaperDollActionBarProfilesPane:OnInitialize()
        PaperDollActionBarProfilesSaveDialog:OnInitialize()
    end

    -- events
    self:RegisterEvent("PLAYER_REGEN_DISABLED", function(...)
        self:UpdateGUI()
    end)

    self:RegisterEvent("PLAYER_REGEN_ENABLED", function(...)
        self:UpdateGUI()
    end)

    self:RegisterEvent("PLAYER_UPDATE_RESTING", function(...)
        self:UpdateGUI()
    end)

    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", function(...)
        if self.specTimer then
            self:CancelTimer(self.specTimer)
        end

        self.specTimer = self:ScheduleTimer(function()
            self.specTimer = nil

            local player = UnitName("player") .. "-" .. GetRealmName("player")
            local spec = GetSpecializationInfo(GetSpecialization())

            if not self.prevSpec or self.prevSpec ~= spec then
                self.prevSpec = spec

                local list = self.db.profile.list
                local profile

                for profile in table.s2k_values(list) do
                    if profile.fav and profile.fav[player .. "-" .. spec] then
                        self:UseProfile(profile)
                    end
                end
            end
        end, 0.1)

        self:UpdateGUI()
    end)

    self:RegisterEvent("UNIT_AURA", function(event, target)
        if target == "player" then
            if self.auraTimer then
                self:CancelTimer(self.auraTimer)
            end

            self.auraTimer = self:ScheduleTimer(function()
                self.auraTimer = nil

                local state = (UnitAura("player", GetSpellInfo(ABP_TOME_OF_CLEAR_MIND_SPELL_ID))
                    or UnitAura("player", GetSpellInfo(ABP_TOME_OF_TRANQUIL_MIND_SPELL_ID))
                    or UnitAura("player", GetSpellInfo(ABP_DUNGEON_PREPARE_SPELL_ID))) and true or nil

                if state ~= self.auraState then
                    self.auraState = state
                    self:UpdateGUI()
                end
            end, 0.1)
        end
    end)

    -- profile sharing
    self:RegisterComm(ABP_COMM_CMD, function(...)
        self:OnCommCmd(...)
    end)

    self:RegisterComm(ABP_COMM_SHARE, function(...)
        self:OnCommShare(...)
    end)
end

function addon:ParseArgs(message)
    local arg, pos = self:GetArgs(message, 1, 1)

    if arg then
        if pos <= #message then
            return arg, message:sub(pos)
        else
            return arg
        end
    end
end

function addon:OnChatCommand(message)
    local cmd, param = self:ParseArgs(message)

    if not cmd then return end

    if cmd == "list" or cmd == "ls" then
        local list = {}

        local profile
        for profile in table.s2k_values({ self:GetProfiles() }) do
            table.insert(list, string.format("|c%s%s|r",
                RAID_CLASS_COLORS[profile.class].colorStr, profile.name
            ))
        end

        if #list > 0 then
            self:Printf(L.msg_profile_list, strjoin(", ", unpack(list)))
        else
            self:Printf(L.msg_profile_list_empty)
        end

    elseif cmd == "save" or cmd == "sv" then
        if param then
            local profile = self:GetProfiles(param, true)

            if profile then
                self:UpdateProfile(profile)
            else
                self:SaveProfile(param)
            end
        end

    elseif cmd == "delete" or cmd == "del" or cmd == "remove" or cmd == "rm" then
        if param then
            local profile = self:GetProfiles(param, true)

            if profile then
                self:DeleteProfile(profile.name)
            else
                self:Printf(L.msg_profile_not_exists, param)
            end
        end

    elseif cmd == "use" or cmd == "load" or cmd == "ld" then
        if param then
            local profile = self:GetProfiles(param, true)

            if profile then
                self:UseProfile(profile)
            else
                self:Printf(L.msg_profile_not_exists, param)
            end
        end

    elseif cmd == "send" or cmd == "share" or cmd == "sh" then
        if param then
            local char, profile

            char, param = self:ParseArgs(param)

            if param then
                profile = self:GetProfiles(param, true)
            else
                profile = self:UpdateProfile({}, true)
            end

            if profile then
                self:CommSendCmd("share", char, profile)
            else
                self:Printf(L.msg_profile_not_exists, param)
            end
        end
    end
end

function addon:ShowTooltip(anchor)
    if not (InCombatLockdown() or (self.tooltip and self.tooltip:IsShown())) then
        if not (qtip:IsAcquired(addonName) and self.tooltip) then
            self.tooltip = qtip:Acquire(addonName, 2, "LEFT")

            self.tooltip.OnRelease = function()
                self.tooltip = nil
            end
        end

        if anchor then
            self.tooltip:SmartAnchorTo(anchor)
            self.tooltip:SetAutoHideDelay(0.05, anchor)
        end

        self:UpdateTooltip(self.tooltip)
    end
end

function addon:UpdateTooltip(tooltip)
    tooltip:Clear()

    local line = tooltip:AddHeader(ABP_ADDON_NAME)

    local profiles = { addon:GetProfiles() }

    if #profiles > 0 then
        local class = select(2, UnitClass("player"))
        local cache = addon:MakeCache()

        line = tooltip:AddLine(L.tooltip_list)
        tooltip:SetCellTextColor(line, 1, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)

        local profile
        for profile in table.s2k_values(profiles) do
            local line

            local name = profile.name
            local color = NORMAL_FONT_COLOR

            if profile.class ~= class then
                color = GRAY_FONT_COLOR
            else
                local fail, total = addon:UseProfile(profile, true, cache)
                if fail > 0 then
                    color = RED_FONT_COLOR
                    name = name .. string.format(" (%d/%d)", fail, total)
                end
            end

            if profile.icon then
                line = tooltip:AddLine(string.format(
                    "  |T%s:14:14:0:0:32:32:0:32:0:32|t %s",
                    profile.icon, name
                ))
            else
                local coords = CLASS_ICON_TCOORDS[profile.class]
                line = tooltip:AddLine(string.format(
                    "  |TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:14:14:0:0:256:256:%d:%d:%d:%d|t %s",
                    coords[1] * 256, coords[2] * 256, coords[3] * 256, coords[4] * 256,
                    name
                ))
            end

            tooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)

            tooltip:SetLineScript(line, "OnMouseUp", function()
                local fail, total = addon:UseProfile(profile, true, cache)

                if fail > 0 then
                    if not self:ShowPopup("CONFIRM_USE_ACTION_BAR_PROFILE", fail, total, { name = profile.name }) then
                        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
                    end
                else
                    addon:UseProfile(profile, false, cache)
                end
            end)
        end
    else
        line = tooltip:AddLine(L.tooltip_list_empty)
        tooltip:SetCellTextColor(line, 1, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
    end

    tooltip:AddLine("")

    tooltip:UpdateScrolling()
    tooltip:Show()
end

function addon:UpdateGUI()
    if self.updateTimer then
        self:CancelTimer(self.updateTimer)
    end

    self.updateTimer = self:ScheduleTimer(function()
        self.updateTimer = nil

        if PaperDollActionBarProfilesPane and PaperDollActionBarProfilesPane:IsShown() then
            PaperDollActionBarProfilesPane:Update()
        end

        if self.tooltip and self.tooltip:IsShown() then
            if InCombatLockdown() then
                self.tooltip:Hide()
            else
                self:UpdateTooltip(self.tooltip)
            end
        end
    end, 0.1)
end

local PET_JOURNAL_FLAGS = { LE_PET_JOURNAL_FILTER_COLLECTED, LE_PET_JOURNAL_FILTER_NOT_COLLECTED }

function addon:SavePetJournalFilters()
    local saved = { flag = {}, source = {}, type = {} }

    saved.text = C_PetJournal.GetSearchFilter()

    local i
    for i in table.s2k_values(PET_JOURNAL_FLAGS) do
        saved.flag[i] = C_PetJournal.IsFilterChecked(i)
    end

    for i = 1, C_PetJournal.GetNumPetSources() do
        saved.source[i] = C_PetJournal.IsPetSourceChecked(i)
    end

    for i = 1, C_PetJournal.GetNumPetTypes() do
        saved.type[i] = C_PetJournal.IsPetTypeChecked(i)
    end

    return saved
end

function addon:RestorePetJournalFilters(saved)
    C_PetJournal.SetSearchFilter(saved.text)

    local i
    for i in table.s2k_values(PET_JOURNAL_FLAGS) do
        C_PetJournal.SetFilterChecked(i, saved.flag[i])
    end

    for i = 1, C_PetJournal.GetNumPetSources() do
        C_PetJournal.SetPetSourceChecked(i, saved.source[i])
    end

    for i = 1, C_PetJournal.GetNumPetTypes() do
        C_PetJournal.SetPetTypeFilter(i, saved.type[i])
    end
end

function addon:InjectPaperDollSidebarTab(name, frame, icon, texCoords)
    local tab = #PAPERDOLL_SIDEBARS + 1

    PAPERDOLL_SIDEBARS[tab] = { name = name, frame = frame, icon = icon, texCoords = texCoords, IsActive = function() return true end }

    CreateFrame(
        "Button", "PaperDollSidebarTab" .. tab, PaperDollSidebarTabs,
        "PaperDollSidebarTabTemplate", tab
    )

    self:LineUpPaperDollSidebarTabs()

    if not self.prevSetLevel then
        self.prevSetLevel = PaperDollFrame_SetLevel

        PaperDollFrame_SetLevel = function(...)
            self.prevSetLevel(...)

            local extra = #PAPERDOLL_SIDEBARS - ABP_DEFAULT_PAPERDOLL_NUM_TABS

            if CharacterFrameInsetRight:IsVisible() then
                local index
                for index = 1, CharacterLevelText:GetNumPoints() do
                    local point, relTo, relPoint, x, y = CharacterLevelText:GetPoint(index)

                    if point == "CENTER" then
                        CharacterLevelText:SetPoint(
                            point, relTo, relPoint,
                            x - (20 + 10 * extra), y
                        )
                    end
                end
            end
        end
    end
end

function addon:LineUpPaperDollSidebarTabs()
    local extra = #PAPERDOLL_SIDEBARS - ABP_DEFAULT_PAPERDOLL_NUM_TABS
    local prev

    local index
    for index = 1, #PAPERDOLL_SIDEBARS do
        local tab = _G["PaperDollSidebarTab" .. index]
        if tab then
            tab:ClearAllPoints()
            tab:SetPoint("BOTTOMRIGHT", (extra < 2 and -20) or (extra < 3 and -10) or 0, 0)

            if prev then
                prev:ClearAllPoints()
                prev:SetPoint("RIGHT", tab, "LEFT", -4, 0)
            end

            prev = tab
        end
    end
end

function addon:EncodeLink(data)
    return data:gsub(".", function(x)
        return ((x:byte() < 32 or x:byte() == 127 or x == "|" or x == ":" or x == "[" or x == "]" or x == "~") and string.format("~%02x", x:byte())) or x
    end)
end

function addon:DecodeLink(data)
    return data:gsub("~[0-9A-Fa-f][0-9A-Fa-f]", function(x)
        return string.char(tonumber(x:sub(2), 16))
    end)
end

function addon:PackMacro(macro)
    return macro:gsub("^%s+", ""):gsub("%s+\n", "\n"):gsub("\n%s+", "\n"):gsub("%s+$", ""):sub(1)
end

function addon:OnCommCmd(prefix, text, channel, sender)
    if channel == "WHISPER" then
        local type, cmd, id = strsplit(":", text)

        if type == "req" then
            self:SendCommMessage(ABP_COMM_CMD, string.format("ack:%s:%s", cmd, id), "WHISPER", sender)

        elseif type == "ack" then
            if self.commCmds and self.commCmds[id] and self.commCmds[id].cmd == cmd then
                if self.commCmds[id].timer then
                    self:CancelTimer(self.commCmds[id].timer)
                end

                if cmd == "share" then
                    self:SendCommMessage(ABP_COMM_SHARE, self:Serialize(self.commCmds[id].data), "WHISPER", sender)
                end

                self.commCmds[id] = nil
            end
        end
    end
end

function addon:OnCommShare(prefix, text, channel, sender)
    if channel == "WHISPER" then
        local profile = select(2, self:Deserialize(text))

        if profile then
            if not addon:ShowPopup("CONFIRM_RECEIVE_ACTION_BAR_PROFILE", sender, nil, { name = sender, profile = profile }) then
                UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
            end
        end
    end
end

function addon:CommSendCmd(cmd, target, data)
    local id = string.format("%08d", math.random(99999999))

    self.commCmds = self.commCmds or {}

    self.commCmds[id] = {
        data = data,
        cmd = cmd,
        timer = self:ScheduleTimer(function()
            if cmd == "share" then
                local messages = { strsplit("\n", L.chat_share_invite:format(ABP_ADDON_NAME, ABP_ADDON_NAME, ABP_DOWNLOAD_LINK)) }

                local message
                for message in table.s2k_values(messages) do
                    SendChatMessage(message, "WHISPER", nil, target)
                end
            end

            self.commCmds[id] = nil
        end, 5)
    }

    self:SendCommMessage(ABP_COMM_CMD, string.format("req:%s:%s", cmd, id), "WHISPER", target)
end
