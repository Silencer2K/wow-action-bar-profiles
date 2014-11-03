local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_SPELLBOOK_TABS = 10
local MAX_ACTION_BUTTONS = 120

local PET_JOURNAL_FLAGS = { LE_PET_JOURNAL_FLAG_COLLECTED, LE_PET_JOURNAL_FLAG_NOT_COLLECTED, LE_PET_JOURNAL_FLAG_FAVORITES }

local function unpackByIndex(tab, ...)
	local indexes, res = {...}, {}
	local i, j = 0
	for _, j in pairs(indexes) do
		i = i + 1
		res[i] = tab[j]
	end
	return unpack(res, 1, i)
end

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

function addon:PlaceToSlot(slot, checkOnly)
	if not checkOnly then
		PlaceAction(slot)
		ClearCursor()
	end
end

function addon:SavePetJournalFilters()
	local saved = { flag = {}, source = {}, type = {} }

	saved.text = C_PetJournal.GetSearchFilter()

	local i
	for _, i in pairs(PET_JOURNAL_FLAGS) do
		saved.flag[i] = C_PetJournal.IsFlagFiltered(i)
	end

	for i = 1, C_PetJournal.GetNumPetSources() do
		saved.source[i] = C_PetJournal.IsPetSourceFiltered(i)
	end

	for i = 1, C_PetJournal.GetNumPetTypes() do
		saved.type[i] = C_PetJournal.IsPetTypeFiltered(i)
	end

	return saved
end

function addon:RestorePetJournalFilters(saved)
	C_PetJournal.SetSearchFilter(saved.text)

	local i
	for _, i in pairs(PET_JOURNAL_FLAGS) do
		C_PetJournal.SetFlagFilter(i, saved.flag[i])
	end

	for i = 1, C_PetJournal.GetNumPetSources() do
		C_PetJournal.SetPetSourceFilter(i, saved.source[i])
	end

	for i = 1, C_PetJournal.GetNumPetTypes() do
		C_PetJournal.SetPetTypeFilter(i, saved.type[i])
	end
end

function addon:ClearPetJournalFilters()
	C_PetJournal.ClearSearchFilter()

	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true)
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, false)
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, false)

	C_PetJournal.AddAllPetSourcesFilter()
	C_PetJournal.AddAllPetTypesFilter()
end

function addon:UpdateCache(cache, index, id, name, stance)
	cache.id[id] = index

	if name then
		if stance and stance ~= "" then
			cache.name[name .. "|" .. stance] = index
		else
			cache.name[name] = index
		end
	end
end

function addon:MakeCache()
        local spells = { id = {}, name = {} }
        local flyouts = { id = {}, name = {} }
        local items = { id = {}, name = {} }
        local mounts = { id = {}, name = {} }
        local pets = { id = {} }
        local macros = { id = {} }

	local bookIndex
	for bookIndex = 1, MAX_SPELLBOOK_TABS do
		local bookOffset, numSpells, offSpecId = unpackByIndex({ GetSpellTabInfo(bookIndex) }, 3, 4, 6)

		if offSpecId == 0 then
			local spellIndex
			for spellIndex = bookOffset + 1, bookOffset + numSpells do
				local type, id = GetSpellBookItemInfo(spellIndex, BOOKTYPE_SPELL)
				local name, stance = GetSpellBookItemName(spellIndex, BOOKTYPE_SPELL)

				if type == "SPELL" then
					self:UpdateCache(spells, id, id, name, stance)

				elseif type == "FLYOUT" then
					self:UpdateCache(flyouts, spellIndex, id, name)
				end
			end
		end
	end

	local slotIndex
	for slotIndex = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local id = GetInventoryItemID("player", slotIndex)

		if id then
			local name = GetItemInfo(id)
			self:UpdateCache(items, id, id, name)
		end
	end

	local bagIndex
	for bagIndex = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local itemIndex
		for itemIndex = 1, GetContainerNumSlots(bagIndex) do
			local id = GetContainerItemID(bagIndex, itemIndex)

			if id then
				local name = GetItemInfo(id)
				self:UpdateCache(items, id, id, name)
			end
		end
	end

	local playerFaction = (UnitFactionGroup("player") == "Alliance" and 1) or 0

	local mountIndex
	for mountIndex = 1, C_MountJournal.GetNumMounts() do
		local name, id, faction, isCollected = unpackByIndex({ C_MountJournal.GetMountInfo(mountIndex) }, 1, 2, 9, 11)

		if isCollected and (not faction or faction == playerFaction) then
			self:UpdateCache(mounts, id, id, name)
		end
	end

	local saved = self:SavePetJournalFilters()
	self:ClearPetJournalFilters()

	local petIndex
	for petIndex = 1, C_PetJournal:GetNumPets() do
		local petId, id = unpackByIndex({ C_PetJournal.GetPetInfoByIndex(petIndex) }, 1, 11)
		self:UpdateCache(pets, petId, id)
	end

	self:RestorePetJournalFilters(saved)

	local macroIndex
	for macroIndex = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
		local name, icon = GetMacroInfo(macroIndex)

		if name and name ~= "" then
			self:UpdateCache(macros, macroIndex, name .. "|" .. icon)
		end
	end

	return { spells = spells, flyouts = flyouts, items = items, mounts = mounts, pets = pets, macros = macros }
end

function addon:GetFromCache(cache, id, name, stance)
	if stance and stance ~= "" then
		return cache.id[id] or (name and cache.name[name .. "|" .. stance])
	end

	return cache.id[id] or (name and cache.name[name])
end

function addon:RestoreSpell(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][2]
	local name, stance = GetSpellInfo(id)

	local spell = self:GetFromCache(cache.spells, id, name, stance)

	if spell then
		if not checkOnly then
			PickupSpell(spell)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreFlyout(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][2]
	local name = GetFlyoutInfo(id)

	local flyout = self:GetFromCache(cache.flyouts, id, name)

	if (flyout) then
		if not checkOnly then
			PickupSpellBookItem(flyout, BOOKTYPE_SPELL)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreItem(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][2]

	local name = GetItemInfo(id)
	if not name then
		name = profile.actions[slot][5]
	end

	local item = self:GetFromCache(cache.items, id, name)

	if (item) then
		if not checkOnly then
			PickupItem(item)
			self:PlaceToSlot(slot)
		end
		return true
	end

	if PlayerHasToy(id) then
		if not checkOnly then
			PickupItem(id)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreMissingItem(cache, profile, slot, checkOnly)
	local id = unpackByIndex(profile.actions[slot], 2)

	if GetItemInfo(id) then
		if not checkOnly then
			PickupItem(id)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreMount(cache, profile, slot, checkOnly)
	local type, id = unpack(profile.actions[slot])

	if type == "summonmount" then
		id = MOUNT_INDEX_TO_SPELL_ID[id]
	end

	local name = GetSpellInfo(id)

	local mount = self:GetFromCache(cache.mounts, id, name)

	if (mount) then
		if not checkOnly then
			PickupSpell(mount)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestorePet(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][5]

	local pet = self:GetFromCache(cache.pets, id)

	if pet then
		if not checkOnly then
			C_PetJournal.PickupPet(pet)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreMacro(cache, profile, slot, checkOnly)
	local name, icon = unpackByIndex(profile.actions[slot], 5, 6)

	local macro = self:GetFromCache(cache.macros, name .. "|" .. icon)

	if macro then
		if not checkOnly then
			PickupMacro(macro)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:CheckUseProfile(name)
	return addon:UseProfile(name, true)
end

function addon:UseProfile(name, checkOnly)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	local fail, total = 0, 0
	local cache = self:MakeCache()

	if profile then
		local slot
		for slot = 1, MAX_ACTION_BUTTONS do
			if not profile.actions[slot] then
				self:ClearSlot(slot, checkOnly)
			else
				local type, id, subType, spellId = unpack(profile.actions[slot])
				local ok

				if type == "spell" then
					ok = self:RestoreSpell(cache, profile, slot, checkOnly)

				elseif type == "flyout" then
					ok = self:RestoreFlyout(cache, profile, slot, checkOnly)

				elseif type == "item" then
					ok = self:RestoreItem(cache, profile, slot, checkOnly)

					if not ok then
						ok = self:RestoreMissingItem(cache, profile, slot, checkOnly)
						if ok then
							fail = fail + 1
						end
					end

				elseif type == "companion" then
					if subType == "MOUNT" then
						ok = self:RestoreMount(cache, profile, slot, checkOnly)
					end

				elseif type == "summonmount" then
					ok = self:RestoreMount(cache, profile, slot, checkOnly)

				elseif type == "summonpet" then
					ok = self:RestorePet(cache, profile, slot, checkOnly)

				elseif type == "macro" then
					ok = self:RestoreMacro(cache, profile, slot, checkOnly)
				end

				if not ok then
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
				if type == "item" then
					profile.actions[slot] = { type, id, subType, extraId, unpackByIndex({ GetItemInfo(id) }, 1) }

				elseif type == "macro" then
					profile.actions[slot] = { type, id, subType, extraId, unpackByIndex({ GetMacroInfo(id) }, 1, 2) }

				elseif type == "summonpet" then
					profile.actions[slot] = { type, id, subType, extraId, unpackByIndex({ C_PetJournal.GetPetInfoByPetID(id) }, 11) }

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
