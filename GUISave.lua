local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesSaveDialog

function frame:SaveDialogOptions()
    return table.s2k_values({
        { "Actions", "actions" },
        { "EmptySlots", "empty_slots" },
        { "Talents", "talents" },
        { "Macros", "macros" },
        { "PetActions", "pet_actions" },
        { "Bindings", "bindings" },
    }, true)
end

function frame:OnInitialize()
    self.ProfileNameText:SetText(L.gui_profile_name)
    self.ProfileOptionsText:SetText(L.gui_profile_options)

    local option, lang
    for option, lang in self:SaveDialogOptions() do
        _G[self:GetName() .. "Option" .. option .. "Text"]:SetText(" " .. L["option_" .. lang])
    end
end

function frame:OnOkayClick()
    local name = strtrim(self.EditBox:GetText())
    local options = {}

    local option
    for option in self:SaveDialogOptions() do
        options["skip" .. option] = not self["Option" .. option]:GetChecked() or nil
    end

    if self.name then
        if name ~= self.name then
            if addon:GetProfiles(name) then
                UIErrorsFrame:AddMessage(L.error_exists, 1.0, 0.1, 0.1, 1.0)
                return
            end

            addon:RenameProfile(self.name, name, true)

            -- hack: update selection
            PaperDollActionBarProfilesPane.selected = name
        end

        addon:UpdateProfileOptions(name, options)
    else
        if addon:GetProfiles(name) then
            if not addon:ShowPopup("CONFIRM_OVERWRITE_ACTION_BAR_PROFILE", name, nil, { name = name, options = options, hide = self }) then
                UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
            end

            return
        end

        addon:SaveProfile(name, options)
    end

    self:Hide()
end

function frame:OnCancelClick()
    self:Hide()
end

function frame:Update()
    if strtrim(self.EditBox:GetText()) ~= "" then
        self.Okay:Enable()
    else
        self.Okay:Disable()
    end
end

function frame:SetProfile(name)
    self.name = nil
    self.EditBox:SetText("")

    local option
    for option in self:SaveDialogOptions() do
        self["Option" .. option]:SetChecked(true)
        self["Option" .. option]:Enable()

        _G[self:GetName() .. "Option" .. option .. "Text"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end

    if not name then
        if not HasPetSpells() then
            self.OptionPetActions:Disable()
            _G[self:GetName() .. "OptionPetActionsText"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
        end
    else
        self.name = name

        self.EditBox:SetText(name)
        self.EditBox:HighlightText(0)

        local profile = addon:GetProfiles(name)
        if profile then
            for option in self:SaveDialogOptions() do
                self["Option" .. option]:SetChecked(not profile["skip" .. option])
            end

            if not profile.petActions then
                self.OptionPetActions:Disable()
                _G[self:GetName() .. "OptionPetActionsText"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            end
        end
    end

    self:Update()
end
