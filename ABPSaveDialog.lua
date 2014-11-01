local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesSaveDialog

function frame:OnInitialize()
	StaticPopupDialogs.CONFIRM_OVERWRITE_ACTION_BAR_PROFILE = {
		text = L.confirm_overwrite,
		button1 = YES,
		button2 = NO,
		OnAccept = function(self) end,
		OnCancel = function(self) end,
		OnHide = function (self) end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
	}

	self.NameText:SetText(L.save_dialog_title)
end

function frame:OnOkayClick()
	local name = self.EditBox:GetText()

	if self.name then
		if name ~= self.name then
		else
		end
	else
		if addon:GetProfile(name) then
		else
			addon:SaveProfile(name)
			PaperDollActionBarProfilesPane:Update()
			self:Hide()
		end
	end
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
