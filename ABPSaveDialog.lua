local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesSaveDialog

function frame:OnInitialize()
	self.NameText:SetText(L.save_dialog_title)
end

function frame:OnOkayClick()
	self:Hide()
end

function frame:OnCancelClick()
	self:Hide()
end

function frame:Update()
	if self.EditBox:GetText() ~= "" then
		self.Okay:Enable()
	else
		self.Okay:Disable()
	end
end

function frame:SetProfile(name)
	self.name = nil
	self.EditBox:SetText("")

	if name then
		self.name = name

		self.EditBox:SetText(self.name)
		self.EditBox:HighlightText(0)
	end

	self:Update()
end
