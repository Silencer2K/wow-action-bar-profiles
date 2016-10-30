local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesPane

local ACTION_BAR_PROFILE_BUTTON_HEIGHT = 44

function frame:OnInitialize()
    self.scrollBar.doNotHide = 1

    self:SetFrameLevel(CharacterFrameInsetRight:GetFrameLevel() + 1)

    self.UseProfile:SetFrameLevel(self:GetFrameLevel() + 3)
    self.SaveProfile:SetFrameLevel(self:GetFrameLevel() + 3)

    HybridScrollFrame_OnLoad(self)
    self.update = function() self:Update() end

    HybridScrollFrame_CreateButtons(self, "ActionBarProfileButtonTemplate", 2, -(self.UseProfile:GetHeight() + 4))
end

function frame:OnShow()
    self:Update()
end

function frame:OnHide()
    PaperDollActionBarProfilesSaveDialog:Hide()
end

function frame:OnUpdate()
    local class = select(2, UnitClass("player"))

    local button
    for button in table.s2k_values(self.buttons) do
        if button:IsMouseOver() then
            if button.name then
                if button.UnfavButton:IsShown() or button.class ~= class then
                    button.FavButton:Hide()
                else
                    button.FavButton:Show()
                end

                button.DeleteButton:Show()
                button.EditButton:Show()
            else
                button.FavButton:Hide()
                button.DeleteButton:Hide()
                button.EditButton:Hide()
            end

            button.HighlightBar:Show()
        else
            button.FavButton:Hide()
            button.DeleteButton:Hide()
            button.EditButton:Hide()

            button.HighlightBar:Hide()
        end
    end
end

function frame:OnProfileClick(button)
    if button.name then
        self.selected = button.name
        self:Update()

        PaperDollActionBarProfilesSaveDialog:Hide()
    else
        self.selected = nil
        self:Update()

        PaperDollActionBarProfilesSaveDialog:SetProfile(nil)
        PaperDollActionBarProfilesSaveDialog:Show()
    end
end

function frame:OnProfileDoubleClick(button)
    if button.name then
        self:OnProfileClick(button)
        self:OnUseClick()
    end
end

function frame:OnUseClick()
    local cache = addon:MakeCache()
    local fail, total = addon:UseProfile(self.selected, true, cache)

    if fail > 0 then
        if not addon:ShowPopup("CONFIRM_USE_ACTION_BAR_PROFILE", fail, total, { name = self.selected }) then
            UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
        end
    else
        addon:UseProfile(self.selected, false, cache)
    end
end

function frame:OnDeleteClick(button)
    if not addon:ShowPopup("CONFIRM_DELETE_ACTION_BAR_PROFILE", button.name, nil, { name = button.name }) then
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
    end
end

function frame:OnSaveClick()
    if not addon:ShowPopup("CONFIRM_SAVE_ACTION_BAR_PROFILE", self.selected, nil, { name = self.selected }) then
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
    end
end

function frame:OnEditClick(button)
    self:OnProfileClick(button)

    PaperDollActionBarProfilesSaveDialog:SetProfile(button.name)
    PaperDollActionBarProfilesSaveDialog:Show()
end

function frame:OnFavClick(button)
    local player = UnitName("player") .. "-" .. GetRealmName("player")
    local spec = GetSpecializationInfo(GetSpecialization())

    addon:SetDefault(button.name, player .. "-" .. spec)
end

function frame:OnUnfavClick(button)
    local player = UnitName("player") .. "-" .. GetRealmName("player")
    local spec = GetSpecializationInfo(GetSpecialization())

    addon:UnsetDefault(button.name, player .. "-" .. spec)
end

function frame:Update()
    local profiles = { addon:GetProfiles() }
    local rows = #profiles + 1

    HybridScrollFrame_Update(self, rows * ACTION_BAR_PROFILE_BUTTON_HEIGHT + self.UseProfile:GetHeight() + 20, self:GetHeight())

    local offset = HybridScrollFrame_GetOffset(self)

    local player = UnitName("player") .. "-" .. GetRealmName("player")
    local class = select(2, UnitClass("player"))
    local spec = GetSpecializationInfo(GetSpecialization())

    local cache = addon:MakeCache()

    local selected = self.selected
    self.selected = nil

    local i
    for i = 1, #self.buttons do
        local button = self.buttons[i]

        if i + offset <= rows then
            if i + offset ==  1 then
                button.name = nil

                button.text:SetText(L.gui_new_profile)
                button.text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)

                button.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
                button.icon:SetTexCoord(0, 1, 0, 1)

                button.icon:SetSize(30, 30)
                button.icon:SetPoint("LEFT", 7, 0)

                button.SelectedBar:Hide()
                button.UnfavButton:Hide()
            else
                local profile = profiles[i + offset - 1]

                button.name = profile.name
                button.class = profile.class

                local text = profile.name
                local color = NORMAL_FONT_COLOR

                if profile.class ~= class then
                    color = GRAY_FONT_COLOR
                else
                    local fail, total = addon:UseProfile(profile, true, cache)
                    if fail > 0 then
                        color = RED_FONT_COLOR
                        text = text .. string.format(" (%d/%d)", fail, total)
                    end
                end

                button.text:SetText(text)
                button.text:SetTextColor(color.r, color.g, color.b)

                if profile.icon then
                    button.icon:SetTexture(profile.icon)
                    button.icon:SetTexCoord(0, 1, 0, 1)
                else
                    button.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
                    button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[profile.class]))
                end

                button.icon:SetSize(36, 36)
                button.icon:SetPoint("LEFT", 4, 0)

                if selected and selected == profile.name then
                    button.SelectedBar:Show()
                    self.selected = profile.name
                else
                    button.SelectedBar:Hide()
                end

                if addon:IsDefault(profile, player .. "-" .. spec) then
                    button.UnfavButton:Show()
                else
                    button.UnfavButton:Hide()
                end
            end

            if (i + offset) == 1 then
                button.BgTop:Show()
                button.BgMiddle:SetPoint("TOP", button.BgTop, "BOTTOM")
            else
                button.BgTop:Hide()
                button.BgMiddle:SetPoint("TOP")
            end

            if (i + offset) == rows then
                button.BgBottom:Show()
                button.BgMiddle:SetPoint("BOTTOM", button.BgBottom, "TOP")
            else
                button.BgBottom:Hide()
                button.BgMiddle:SetPoint("BOTTOM")
            end

            if (i + offset) % 2 == 0 then
                button.Stripe:SetColorTexture(0.9, 0.9, 1)
                button.Stripe:SetAlpha(0.1)

                button.Stripe:Show()
            else
                button.Stripe:Hide()
            end

            button:Show()
            button:Enable()
        else
            button:Hide()
        end
    end

    if self.selected then
        if InCombatLockdown() then
            self.UseProfile:Disable()
        else
            self.UseProfile:Enable()
        end

        self.SaveProfile:Enable()
    else
        PaperDollActionBarProfilesSaveDialog:Hide()

        self.UseProfile:Disable()
        self.SaveProfile:Disable()
    end
end
