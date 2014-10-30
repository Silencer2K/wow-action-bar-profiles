local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesPane

function frame:OnInitialize()
	self.scrollBar.doNotHide = 1

	self:SetFrameLevel(CharacterFrameInsetRight:GetFrameLevel() + 1)

	self.UseProfile:SetFrameLevel(self:GetFrameLevel() + 3)
	self.SaveProfile:SetFrameLevel(self:GetFrameLevel() + 3)

	self:SetScript("OnShow", function() self:OnShow() end)
	self:SetScript("OnHide", function() self:OnHide() end)
	self:SetScript("OnUpdate", function() self:OnUpdate() end)

	HybridScrollFrame_OnLoad(self)
	self.update = function() self:Update() end

	HybridScrollFrame_CreateButtons(self, "GearSetButtonTemplate", 2, -(self.UseProfile:GetHeight() + 4))
	self:Update()
end

function frame:OnShow()
	HybridScrollFrame_CreateButtons(self, "GearSetButtonTemplate")
	self:Update()
end

function frame:OnHide()
end

function frame:OnUpdate()
	for i = 1, #self.buttons do
		local button = self.buttons[i]

		if (button:IsMouseOver()) then
			if button.name then
				button.DeleteButton:Show()
				button.EditButton:Show()
			else
				button.DeleteButton:Hide()
				button.EditButton:Hide()
			end

			button.HighlightBar:Show()
		else
			button.DeleteButton:Hide()
			button.EditButton:Hide()

			button.HighlightBar:Hide()
		end
	end
end

function frame:Update()
	local profiles = addon:GetProfiles()
	local numRows = #profiles + 1

	HybridScrollFrame_Update(self, numRows * EQUIPMENTSET_BUTTON_HEIGHT + self.UseProfile:GetHeight() + 20, self:GetHeight())

	local scrollOffset = HybridScrollFrame_GetOffset(self)

	for i = 1, #self.buttons do
		local button = self.buttons[i]

		if scrollOffset + i <= numRows then
			if scrollOffset + i ==  1 then
				button.name = nil

				button.text:SetText(L.new_profile)
				button.text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)

				button.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
				button.icon:SetSize(30, 30)
				button.icon:SetPoint("LEFT", 7, 0)

				button.SelectedBar:Hide()
			else
				-- existing profile
			end

			if ((i + scrollOffset) == 1) then
				button.BgTop:Show()
				button.BgMiddle:SetPoint("TOP", button.BgTop, "BOTTOM")
			else
				button.BgTop:Hide()
				button.BgMiddle:SetPoint("TOP")
			end

			if ((i + scrollOffset) == numRows) then
				button.BgBottom:Show()
				button.BgMiddle:SetPoint("BOTTOM", button.BgBottom, "TOP")
			else
				button.BgBottom:Hide()
				button.BgMiddle:SetPoint("BOTTOM")
			end

			if ((i + scrollOffset) % 2 == 0) then
				button.Stripe:SetTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b)
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
end
