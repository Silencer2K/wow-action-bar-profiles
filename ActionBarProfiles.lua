local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceConsole-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local S2K = LibStub("S2KTools-1.0")

local MAX_ACTION_BUTTONS = 120

local PET_JOURNAL_FLAGS = { LE_PET_JOURNAL_FLAG_COLLECTED, LE_PET_JOURNAL_FLAG_NOT_COLLECTED, LE_PET_JOURNAL_FLAG_FAVORITES }

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addonName .. "DB")

	S2K:InjectPaperDollSidebarTab(
		L.charframe_tab,
		"PaperDollActionBarProfilesPane",
		"Interface\\AddOns\\ActionBarProfiles\\textures\\CharDollBtn",
		{ 0, 0.515625, 0, 0.13671875 }
	)

	self:RegisterChatCommand("abp", "OnChatCommand")

	PaperDollActionBarProfilesPane:OnInitialize()
	PaperDollActionBarProfilesSaveDialog:OnInitialize()
end

function addon:OnEnable()
end

function addon:OnDisable()
end

function addon:OnChatCommand(message)
	local cmd, pos = self:GetArgs(message, 1, 1)
	local param = message:sub(pos)

	if cmd and cmd == "use" and param then
		self:UseProfile(param)
	end
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
		ClearCursor()
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

function addon:PlaceItemToSlot(slot, itemId, checkOnly)
	if not checkOnly then
		PickupItem(itemId)
		self:PlaceToSlot(slot)
	end
end

function addon:PlaceSpellToSlot(slot, spellId, checkOnly)
	if not checkOnly then
		PickupSpell(spellId)
		self:PlaceToSlot(slot)
	end
end

function addon:ClearPetSlot(slot, checkOnly)
	if not checkOnly then
		ClearCursor()
		PickupPetAction(slot)
		ClearCursor()
	end
end

function addon:PlaceToPetSlot(slot, checkOnly)
	if not checkOnly then
		PickupPetAction(slot)
		ClearCursor()
	end
end

function addon:UpdateCache(cache, value, id, name, stance)
	cache.id[id] = value

	if name then
		if stance and stance ~= "" then
			cache.name[name .. "|" .. stance] = value
		else
			cache.name[name] = value
		end
	end
end

function addon:PreloadSpells()
	local spells = { id = {}, name = {} }
	local flyouts = { id = {}, name = {} }

	local bookTabs = {}

	local bookIndex
	for bookIndex = 1, GetNumSpellTabs() do
		local bookOffset, numSpells, offSpecId = unpackByIndex({ GetSpellTabInfo(bookIndex) }, 3, 4, 6)

		if bookOffset and offSpecId == 0 then
			table.insert(bookTabs, { type = BOOKTYPE_SPELL, from = bookOffset + 1, to = bookOffset + numSpells })
		end
	end

	local profIndex
	for _, profIndex in pairs({ GetProfessions() }) do
		if profIndex then
			local bookOffset, numSpells = unpackByIndex({ GetProfessionInfo(profIndex) }, 6, 5)

			table.insert(bookTabs, { type = BOOKTYPE_PROFESSION, from = bookOffset + 1, to = bookOffset + numSpells })
		end
	end

	local bookTab
	for _, bookTab in pairs(bookTabs) do
		local spellIndex
		for spellIndex = bookTab.from, bookTab.to do
			local type, spellId = GetSpellBookItemInfo(spellIndex, bookTab.type)
			local name, stance = GetSpellBookItemName(spellIndex, bookTab.type)

			if type == "SPELL" then
				self:UpdateCache(spells, spellId, spellId, name, stance)

			elseif type == "FLYOUT" then
				self:UpdateCache(flyouts, spellIndex, spellId, name)
			end
		end
	end

	return spells, flyouts
end

function addon:PreloadItems()
	local items = { id = {}, name = {} }

	local slotIndex
	for slotIndex = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemId = GetInventoryItemID("player", slotIndex)

		if itemId then
			local name = GetItemInfo(itemId)
			self:UpdateCache(items, itemId, itemId, name)
		end
	end

	local bagIndex
	for bagIndex = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local itemIndex
		for itemIndex = 1, GetContainerNumSlots(bagIndex) do
			local itemId = GetContainerItemID(bagIndex, itemIndex)

			if itemId then
				local name = GetItemInfo(itemId)
				self:UpdateCache(items, itemId, itemId, name)
			end
		end
	end

	return items
end

function addon:PreloadMounts()
	local mounts = { id = {}, name = {} }

	local playerFaction = (UnitFactionGroup("player") == "Alliance" and 1) or 0

	local mountIndex
	for mountIndex = 1, C_MountJournal.GetNumMounts() do
		local name, spellId, faction, isCollected = unpackByIndex({ C_MountJournal.GetMountInfo(mountIndex) }, 1, 2, 9, 11)

		if isCollected and (not faction or faction == playerFaction) then
			self:UpdateCache(mounts, spellId, spellId, name)
		end
	end

	return mounts
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

function addon:PreloadPets()
	local pets = { id = {} }

	local saved = self:SavePetJournalFilters()

	C_PetJournal.ClearSearchFilter()

	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true)
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, false)
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, false)

	C_PetJournal.AddAllPetSourcesFilter()
	C_PetJournal.AddAllPetTypesFilter()

	local petIndex
	for petIndex = 1, C_PetJournal:GetNumPets() do
		local petId, creatureId = unpackByIndex({ C_PetJournal.GetPetInfoByIndex(petIndex) }, 1, 11)
		self:UpdateCache(pets, petId, creatureId)
	end

	self:RestorePetJournalFilters(saved)

	return pets
end

function addon:PreloadMacros()
	local macros = { id = {}, name = {} } -- id - "name|icon", name - "name"

	local macroIndex
	for macroIndex = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
		local name, icon = GetMacroInfo(macroIndex)

		if name and name ~= "" then
			self:UpdateCache(macros, macroIndex, name .. "|" .. icon, name)
		end
	end

	return macros
end

function addon:PreloadPetSpells()
	local petSpells = { id = {}, name = {} } -- id - "icon"

	local numSpells = HasPetSpells()
	if numSpells then
		local spellIndex
		for spellIndex = 1, numSpells do
			local name, stance = GetSpellBookItemName(spellIndex, BOOKTYPE_PET)
			local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE_PET)

			self:UpdateCache(petSpells, spellIndex, icon, name, stance)
		end
	end

	return petSpells
end

function addon:MakeCache()
	local spells, flyouts = self:PreloadSpells()
	local items = self:PreloadItems()
	local mounts = self:PreloadMounts()
	local pets = self:PreloadPets()
	local macros = self:PreloadMacros()
	local petSpells = self:PreloadPetSpells()

	return { spells = spells, flyouts = flyouts, items = items, mounts = mounts,
		pets = pets, macros = macros, petSpells = petSpells }
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

	local spellId = self:GetFromCache(cache.spells, id, name, stance)

	if spellId then
		self:PlaceSpellToSlot(slot, spellId, checkOnly)
		return true
	end
end

function addon:RestoreFlyout(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][2]
	local name = GetFlyoutInfo(id)

	local flyoutIndex = self:GetFromCache(cache.flyouts, id, name)

	if (flyoutIndex) then
		if not checkOnly then
			PickupSpellBookItem(flyoutIndex, BOOKTYPE_SPELL)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreItem(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][2]
	local name = GetItemInfo(id) or profile.actions[slot][5]

	if PlayerHasToy(id) then
		self:PlaceItemToSlot(slot, id, checkOnly)
		return true
	end

	local itemId = self:GetFromCache(cache.items, id, name)

	if itemId then
		self:PlaceItemToSlot(slot, itemId, checkOnly)
		return true
	end

	local factItemId = S2K:GetFactionalItem(({ UnitFactionGroup("player") })[1], id)

	if factItemId then
		local factItemName = GetItemInfo(factItemId)

		itemId = self:GetFromCache(cache.items, factItemId, factItemName)

		if itemId then
			self:PlaceItemToSlot(slot, itemId, checkOnly)
			return true
		end
	end

	for _, itemId in pairs({ S2K:GetSimilarItems(id) }) do
		if cache.items.id[itemId] then
			self:PlaceItemToSlot(slot, itemId, checkOnly)
			return true
		end
	end
end

function addon:RestoreMissingItem(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][2]

	local itemId = S2K:GetFactionalItem(({ UnitFactionGroup("player") })[1], id) or id

	if GetItemInfo(itemId) then
		self:PlaceItemToSlot(slot, itemId, checkOnly)
		return true
	end
end

function addon:RestoreMount(cache, profile, slot, checkOnly)
	local type, id = unpack(profile.actions[slot])

	if type == "summonmount" then
		id = S2K:GetMountSpell(id)
	end

	local name = GetSpellInfo(id)

	local spellId = self:GetFromCache(cache.mounts, id, name)

	if (spellId) then
		self:PlaceSpellToSlot(slot, spellId, checkOnly)
		return true
	end
end

function addon:RestorePet(cache, profile, slot, checkOnly)
	local id = profile.actions[slot][5]

	local petId = self:GetFromCache(cache.pets, id)

	if petId then
		if not checkOnly then
			C_PetJournal.PickupPet(petId)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreMacro(cache, profile, slot, checkOnly)
	local name, icon = unpackByIndex(profile.actions[slot], 5, 6)

	local macro = self:GetFromCache(cache.macros, name .. "|" .. icon, name)

	if macro then
		if not checkOnly then
			PickupMacro(macro)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestoreEquipSet(cache, profile, slot, checkOnly)
	local name = profile.actions[slot][2]

	if (GetEquipmentSetInfoByName(name)) then
		if not checkOnly then
			PickupEquipmentSetByName(name)
			self:PlaceToSlot(slot)
		end
		return true
	end
end

function addon:RestorePetSpell(cache, profile, slot, checkOnly)
	local icon, isToken = unpackByIndex(profile.petActions[slot], 3, 4)

	icon = (isToken and _G[icon]) or icon

	local spellIndex = self:GetFromCache(cache.petSpells, icon)

	if (spellIndex) then
		if not checkOnly then
			PickupSpellBookItem(spellIndex, BOOKTYPE_PET)
			self:PlaceToPetSlot(slot)
		end
		return true
	end
end

function addon:UseProfile(name, checkOnly, cache)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	if not cache then
		cache = self:MakeCache()
	end

	local fail, total = 0, 0

	if profile then
		local slot
		for slot = 1, MAX_ACTION_BUTTONS do
			if not profile.skip_empty_slots then
				self:ClearSlot(slot, checkOnly)
			end

			if profile.actions[slot] then
				local type, id, subType, extraId = unpack(profile.actions[slot])

				if type == "spell" then
					if not profile.skip_spells then
						total = total + 1
						fail = fail + ((self:RestoreSpell(cache, profile, slot, checkOnly) and 0) or 1)
					end

				elseif type == "flyout" then
					if not profile.skip_spells then
						total = total + 1
						fail = fail + ((self:RestoreFlyout(cache, profile, slot, checkOnly) and 0) or 1)
					end

				elseif type == "item" then
					if not profile.skip_items then
						total = total + 1
						ok = self:RestoreItem(cache, profile, slot, checkOnly)

						if not ok then
							fail = fail + 1
							self:RestoreMissingItem(cache, profile, slot, checkOnly)
						end
					end

				elseif type == "companion" then
					if not profile.skip_companions then
						if subType == "MOUNT" then
							total = total + 1
							fail = fail + ((self:RestoreMount(cache, profile, slot, checkOnly) and 0) or 1)
						end
					end

				elseif type == "summonmount" then
					if not profile.skip_companions then
						total = total + 1
						fail = fail + ((self:RestoreMount(cache, profile, slot, checkOnly) and 0) or 1)
					end

				elseif type == "summonpet" then
					if not profile.skip_companions then
						total = total + 1
						fail = fail + ((self:RestorePet(cache, profile, slot, checkOnly) and 0) or 1)
					end

				elseif type == "macro" then
					if id > 0 then
						if not profile.skip_macros then
							total = total + 1
							fail = fail + ((self:RestoreMacro(cache, profile, slot, checkOnly) and 0) or 1)
						end
					end

				elseif type == "equipmentset" then
					if not profile.skip_equip_sets then
						total = total + 1
						fail = fail + ((self:RestoreEquipSet(cache, profile, slot, checkOnly) and 0) or 1)
					end
				end
			end
		end

		if not profile.skip_pet_spells and HasPetSpells() and profile.petActions then
			for slot = 1, NUM_PET_ACTION_SLOTS do
				if not profile.skip_empty_slots then
					self:ClearPetSlot(slot, checkOnly)
				end

				if profile.petActions[slot] then
					total = total + 1
					fail = fail + ((self:RestorePetSpell(cache, profile, slot, checkOnly) and 0) or 1)
				end
			end
		end
	end

	return fail, total
end

function addon:SaveProfile(name, options)
	local profiles = self.db.global.profiles or {}
	self.db.global.profiles = profiles

	profiles[name] = { name = name }

	self:UpdateProfileParams(name, nil, options)
	self:UpdateProfileBars(name)
end

function addon:UpdateProfileParams(name, newName, options)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	if profile then
		if newName and name ~= newName then
			profiles[name] = nil
			profiles[newName] = profile

			profile.name = newName
		end

		local key
		for key in pairs(profile) do
			if key:sub(1, 5) == "skip_" then
				profile[key] = nil
			end
		end

		for key in pairs(options) do
			profile[key] = options[key]
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
		profile.petActions = nil

		local slot
		for slot = 1, MAX_ACTION_BUTTONS do
			local type, id, subType, extraId = GetActionInfo(slot)

			if type then
				if type == "item" then
					profile.actions[slot] = { type, id, subType, extraId, ({ GetItemInfo(id) })[1] }

				elseif type == "macro" then
					if id > 0 then
						profile.actions[slot] = { type, id, subType, extraId, unpackByIndex({ GetMacroInfo(id) }, 1, 2) }
					end

				elseif type == "summonpet" then
					profile.actions[slot] = { type, id, subType, extraId, ({ C_PetJournal.GetPetInfoByPetID(id) })[11] }

				else
					profile.actions[slot] = { type, id, subType, extraId }
				end
			end
		end

		if HasPetSpells() then
			profile.petActions = {}

			local petSpells = self:PreloadPetSpells()

			for slot = 1, NUM_PET_ACTION_SLOTS do
				local name, stance, icon, isToken = GetPetActionInfo(slot)
				if name then
					if not isToken and not self:GetFromCache(petSpells, icon) then
						local spellIndex = self:GetFromCache(petSpells, icon, name, stance)
						if spellIndex then
							icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE_PET)
						end
					end

					profile.petActions[slot] = { name, stance, icon, isToken }
				end
			end
		end
	end
end

function addon:DeleteProfile(name)
	local profiles = self.db.global.profiles or {}

	profiles[name] = nil
end
