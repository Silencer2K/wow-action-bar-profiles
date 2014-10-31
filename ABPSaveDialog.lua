local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local saveDialog = PaperDollActionBarProfilesSaveDialog

function saveDialog:OnInitialize()
	self.NameText:SetText(L.save_dialog_title)
end
