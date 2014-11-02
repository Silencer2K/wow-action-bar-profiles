local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_ACTION_BUTTONS = 120
local MAX_GLOBAL_MACROS = 120

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addonName .. "DB")

	self:InjectPaperDollSidebarTab(
		L.charframe_tab,
		"PaperDollActionBarProfilesPane",
		"Interface\\AddOns\\ActionBarProfiles\\assets\\CharDollBtn",
		{ 0, 0.515625, 0, 0.13671875 }
	)

	PaperDollActionBarProfilesPane:OnInitialize()
	PaperDollActionBarProfilesSaveDialog:OnInitialize()
end

function addon:InjectPaperDollSidebarTab(name, frame, icon, texCoords)
	local tabIndex = #PAPERDOLL_SIDEBARS + 1

	PAPERDOLL_SIDEBARS[tabIndex] = { name = name, frame = frame, icon = icon, texCoords = texCoords }

	local tabButton = CreateFrame("Button", "PaperDollSidebarTab" .. tabIndex, PaperDollSidebarTabs, "PaperDollSidebarTabTemplate", tabIndex)

	tabButton:SetPoint("BOTTOMRIGHT", -30, 0)

	local prevTabButton = _G["PaperDollSidebarTab" .. (tabIndex - 1)]

	prevTabButton:ClearAllPoints()
	prevTabButton:SetPoint("RIGHT", tabButton, "LEFT", -4, 0)

	local prevSetLevel = PaperDollFrame_SetLevel

	PaperDollFrame_SetLevel = function()
		prevSetLevel()

		if CharacterFrameInsetRight:IsVisible() then
			local i
			for i = 1, CharacterLevelText:GetNumPoints() do
				point, relativeTo, relativePoint, xOffset, yOffset = CharacterLevelText:GetPoint(i)

				if point == "CENTER" then
					CharacterLevelText:SetPoint(point, relativeTo, relativePoint, xOffset - 30, yOffset)
				end
			end
		end
	end
end

function addon:OnEnable()
end

function addon:OnDisable()
end

function addon:GetSortedProfiles()
	local profiles = self.db.global.profiles or {}

	local sorted = {}
	for k, v in pairs(profiles) do
		v.name = k
		table.insert(sorted, v)
	end

	local class = select(2, UnitClass("player"))

	table.sort(sorted, function(a, b)
		if a.class == b.class then
			return a.name < b.name
		else
			return a.class == class
		end
	end)

	return sorted
end

function addon:GetProfile(name)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	if profile then
		profile.name = name
		return profile
	end

	return
end

function addon:ClearSlot(slot, checkOnly)
	if not checkOnly then
		PickupAction(slot)
		ClearCursor()
	end
end

function addon:PreloadSpells()
	self.spellsById = {}
	self.spellsByName = {}
	self.spellsByIcon = {}

	self.flyoutsById = {}

	local i
	for i = 1, MAX_SKILLLINE_TABS do
		local _, _, offset, numSpells, _, offSpecId = GetSpellTabInfo(i)

		if offSpecId == 0 then
			local j
			for j = offset + 1, offset + numSpells do
				local type, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)

				if type == "SPELL" then
					self.spellsById[id] = j

					local name, stance = GetSpellBookItemName(j, BOOKTYPE_SPELL)
					if stance and stance ~= "" then
						self.spellsByName[name .. "|" .. stance] = j
					else
						self.spellsByName[name] = j
					end

					local icon = GetSpellBookItemTexture(j, BOOKTYPE_SPELL)
					self.spellsByIcon[icon] = j

				elseif type == "FLYOUT" then
					self.flyoutsById[id] = j
				end
			end
		end
	end
end

function addon:RestoreSpell(profile, slot, checkOnly)
	local _, id, _, _, name, stance, icon = unpack(profile.actions[slot])

	local spell
	if stance and stance ~= "" then
		spell = self.spellsById[id] or
			self.spellsByName[name .. "|" .. stance] or
			self.spellsByIcon[icon]
	else
		spell = self.spellsById[id] or
			self.spellsByName[name] or
			self.spellsByIcon[icon]
	end

	if (spell) then
		if not checkOnly then
			PickupSpellBookItem(spell, BOOKTYPE_SPELL)
			PlaceAction(slot)
			ClearCursor()
		end
		return true
	end

	self:ClearSlot(slot, checkOnly)
end

function addon:RestoreFlyout(profile, slot, checkOnly)
	local _, id = unpack(profile.actions[slot])

	local flyout = self.flyoutsById[id]

	if (flyout) then
		if not checkOnly then
			PickupSpellBookItem(flyout, BOOKTYPE_SPELL)
			PlaceAction(slot)
			ClearCursor()
		end
		return true
	end

	self:ClearSlot(slot, checkOnly)
end

function addon:PreloadMounts()
	self.mountsById = {}
	self.mountsByName = {}
	self.mountsByIcon = {}

	local i
	for i = 1, C_MountJournal.GetNumMounts() do
		local name, id, icon = C_MountJournal.GetMountInfo(i)

		self.mountsById[id] = i
		self.mountsByName[name] = i
		self.mountsByIcon[icon] = i
	end
end

function addon:RestoreMount(profile, slot, checkOnly)
	local _, id, _, _, name, _, icon = unpack(profile.actions[slot])

	local mount = self.mountsById[id] or
		self.mountsByName[name] or
		self.mountsByIcon[icon]

	if (mount) then
		if not checkOnly then
			C_MountJournal.Pickup(mount)
			PlaceAction(slot)
			ClearCursor()
		end
		return true
	end

	self:ClearSlot(slot, checkOnly)
end

function addon:CheckUseProfile(name)
	return addon:UseProfile(name, true)
end

function addon:UseProfile(name, checkOnly)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	local fail, total = 0, 0

	self:PreloadSpells()
	self:PreloadMounts()

	if profile then
		local slot
		for slot = 1, MAX_ACTION_BUTTONS do
			if not profile.actions[slot] then
				self:ClearSlot(slot, checkOnly)
			else
				local type, id, subType, spellId = unpack(profile.actions[slot])

				if type == "spell" then
					if not self:RestoreSpell(profile, slot, checkOnly) then
						fail = fail + 1
					end
				elseif type == "flyout" then
					if not self:RestoreFlyout(profile, slot, checkOnly) then
						fail = fail + 1
					end
				elseif type == "companion" then
					if subType == "MOUNT" then
						if not self:RestoreMount(profile, slot, checkOnly) then
							fail = fail + 1
						end
					else
						self:ClearSlot(slot, checkOnly)
						fail = fail + 1
					end
				else
					self:ClearSlot(slot, checkOnly)
					fail = fail + 1
				end
			end
			total = total + 1
		end
	end

	return fail, total
end

function addon:SaveProfile(name)
	local profiles = self.db.global.profiles or {}
	self.db.global.profiles = profiles

	profiles[name] = { name = name }

	self:UpdateProfileParams(name)
	self:UpdateProfileBars(name)
end

function addon:UpdateProfileParams(name, newName)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	if profile then
		if newName and name ~= newName then
			profiles[name] = nil
			profiles[newName] = profile

			profile.name = newName
		end
	end
end

function addon:UpdateProfileBars(name)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	if profile then
		profile.class = select(2, UnitClass("player"))
		profile.owner = string.format("%s-%s", GetUnitName("player"), GetRealmName())

		profile.actions = {}

		for slot = 1, MAX_ACTION_BUTTONS do
			local type, id, subType, extraId = GetActionInfo(slot)

			if type then
				if type == "spell" then
					profile.actions[slot] = { type, id, subType, extraId, GetSpellInfo(id) }

				elseif type == "spell" then
					if subType == "MOUNT" then
						profile.actions[slot] = { type, id, subType, extraId, GetSpellInfo(id) }
					else
						profile.actions[slot] = { type, id, subType, extraId }
					end

				elseif type == "item" then
					profile.actions[slot] = { type, id, subType, extraId, GetItemInfo(id) }

				elseif type == "flyout" then
					profile.actions[slot] = { type, id, subType, extraId, GetFlyoutInfo(id) }

				elseif type == "macro" then
					profile.actions[slot] = { type, id, subType, extraId, GetMacroInfo(id) }

				elseif type == "summonmount" then -- convert to legacy format
					local legacyId = MOUNT_INDEX_TO_SPELL_ID[id]
					profile.actions[slot] = { "companion", legacyId, "MOUNT", nil, GetSpellInfo(legacyId) }

				elseif type == "summonpet" then
					profile.actions[slot] = { type, id, subType, extraId, C_PetJournal.GetPetInfoByPetID(id) }

				else
					profile.actions[slot] = { type, id, subType, extraId }
				end
			end
		end
	end
end

function addon:DeleteProfile(name)
	local profiles = self.db.global.profiles or {}

	profiles[name] = nil
end
