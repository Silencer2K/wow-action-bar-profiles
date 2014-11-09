local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local frame = PaperDollActionBarProfilesSaveDialog

function frame:dialogOptions()
  return tableIterator({
    { "EmptySlots", "empty_slots" },
    { "Spells", "spells" },
    { "Items", "items" },
    { "Companions", "companions" },
    { "Macros", "macros" },
    { "EquipSets", "equip_sets" },
    { "PetSpells", "pet_spells" },
  }, true)
end

function frame:OnInitialize()
  StaticPopupDialogs.CONFIRM_OVERWRITE_ACTION_BAR_PROFILE = {
    text = L.confirm_overwrite,
    button1 = YES,
    button2 = NO,
    OnAccept = function(popup) self:OnOverwriteConfirm(popup) end,
    OnCancel = function(popup) end,
    OnHide = function(popup) end,
    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
  }

  self.ProfileNameText:SetText(L.profile_name)
  self.ProfileOptionsText:SetText(L.profile_options)

  local v1, v2
  for v1, v2 in self:dialogOptions() do
    _G[self:GetName() .. "Option" .. v1 .. "Text"]:SetText(" " .. L["option_" .. v2])
  end
end

function frame:OnOkayClick()
  local name = self.EditBox:GetText()

  local options = {}

  local v1, v2
  for v1, v2 in self:dialogOptions() do
    options["skip_" .. v2] = not self["Option" .. v1]:GetChecked() or nil
  end

  if self.name then
    if name ~= self.name then
      if addon:GetProfile(name) then
        UIErrorsFrame:AddMessage(L.error_exists, 1.0, 0.1, 0.1, 1.0)
        return
      end
    end
    addon:UpdateProfileParams(self.name, name, options)
  else
    if addon:GetProfile(name) then
      local popup = StaticPopup_Show("CONFIRM_OVERWRITE_ACTION_BAR_PROFILE", name)
      if popup then
        popup.name = name
        popup.options = options
      else
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
      end
      return
    end
    addon:SaveProfile(name, options)
  end

  PaperDollActionBarProfilesPane:Update()
  self:Hide()
end

function frame:OnOverwriteConfirm(popup)
  addon:SaveProfile(popup.name, popup.options)

  PaperDollActionBarProfilesPane:Update()
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

  local v1, v2
  for v1, v2 in self:dialogOptions() do
    self["Option" .. v1]:SetChecked(true)
  end

  self.OptionPetSpells:Enable()

  if not name then
    if not HasPetSpells() then
      self.OptionPetSpells:Disable()
    end
  else
    self.name = name

    self.EditBox:SetText(self.name)
    self.EditBox:HighlightText(0)

    local profile = addon:GetProfile(name)

    if profile then
      for v1, v2 in self:dialogOptions() do
        self["Option" .. v1]:SetChecked(not profile["skip_" .. v2])
      end

      if not profile.petActions then
        self.OptionPetSpells:SetChecked(true)
        self.OptionPetSpells:Disable()
      end
    end
  end

  self:Update()
end
