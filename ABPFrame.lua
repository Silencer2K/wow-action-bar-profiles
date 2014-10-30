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

function frame:Update()
	local profiles = addon:GetProfiles()
	local numRows = #profiles + 1

	HybridScrollFrame_Update(self, numRows * EQUIPMENTSET_BUTTON_HEIGHT + self.UseProfile:GetHeight() + 20, self:GetHeight())

	local scrollOffset = HybridScrollFrame_GetOffset(self)

	for i = 1, #self.buttons do
		local button = self.buttons[i]

		if scrollOffset + i <= numRows then
			if scrollOffset + i ==  1 then
				-- add new profile
			else
				-- existing profile
			end

			button:Show()
			button:Enable()
		else
			button:Hide()
		end
	end
end
