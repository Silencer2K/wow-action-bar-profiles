local addonName = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesPane

function frame:OnInitialize()
	self.scrollBar.doNotHide = 1

	self:SetFrameLevel(CharacterFrameInsetRight:GetFrameLevel() + 1)

	self.UseProfile:SetFrameLevel(self:GetFrameLevel() + 3)
	self.SaveProfile:SetFrameLevel(self:GetFrameLevel() + 3)
end
