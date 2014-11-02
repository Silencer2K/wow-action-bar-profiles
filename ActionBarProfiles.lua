local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_ACTION_BUTTONS = 120
local MAX_GLOBAL_MACROS = 120

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

function addon:PutToSlot(slot, checkOnly)
	if not checkOnly then
		PlaceAction(slot)
		ClearCursor()
	end
end

function addon:UpdateCache(cache, index, id, name, stance, icon)
	cache.id[id] = index

	if stance and stance ~= "" then
		cache.name[name .. "|" .. stance] = index
	else
		cache.name[name] = index
	end

	if icon then
		cache.icon[icon] = index
	end
end

function addon:MakeCache()
        local spells = { id = {}, name = {}, icon = {} }
        local flyouts = { id = {}, name = {}, icon = {} }
        local items = { id = {}, name = {}, icon = {} }
        local mounts = { id = {}, name = {}, icon = {} }

	local bookIndex, spellIndex
	for bookIndex = 1, MAX_SKILLLINE_TABS do
		local bookOffset, numSpells, offSpecId = unpackByIndex({ GetSpellTabInfo(bookIndex) }, 3, 4, 6)

		if offSpecId == 0 then
			for spellIndex = bookOffset + 1, bookOffset + numSpells do
				local type, id = GetSpellBookItemInfo(spellIndex, BOOKTYPE_SPELL)
				local name, stance = GetSpellBookItemName(spellIndex, BOOKTYPE_SPELL)
				local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE_SPELL)

				if type == "SPELL" then
					self:UpdateCache(spells, spellIndex, id, name, stance, icon)
				elseif type == "FLYOUT" then
					self:UpdateCache(flyouts, spellIndex, id, name, stance, icon)
				end
			end
		end
	end

	local playerFaction = (UnitFactionGroup("player") == "Alliance" and 1) or 0

	local mountIndex
	for mountIndex = 1, C_MountJournal.GetNumMounts() do
		local name, id, icon, faction, isCollected = unpackByIndex({ C_MountJournal.GetMountInfo(mountIndex) }, 1, 2, 3, 9, 11)

		if isCollected and (not faction or faction == playerFaction) then
			self:UpdateCache(mounts, mountIndex, id, name, nil, icon)
		end
	end

	return { spells = spells, flyouts = flyouts, items = items, mounts = mounts }
end

function addon:GetFromCache(cache, id, name, stance, icon)
	if stance and stance ~= "" then
		return cache.id[id] or cache.name[name .. "|" .. stance] or (icon and cache.icon[icon])
	end

	return cache.id[id] or cache.name[name] or (icon and cache.icon[icon])
end

function addon:RestoreSpell(cache, profile, slot, checkOnly)
	local id, name, stance, icon = unpackByIndex(profile.actions[slot], 2, 5, 6, 7)

	local spell = self:GetFromCache(cache, id, name, stance, icon)

	if spell then
		if not checkOnly then
			PickupSpellBookItem(spell, BOOKTYPE_SPELL)
			self:PutToSlot(slot)
		end
		return true
	end
end

function addon:RestoreFlyout(cache, profile, slot, checkOnly)
	local id, name = unpackByIndex(profile.actions[slot], 2, 5)

	local flyout = self:GetFromCache(cache, id, name)

	if (flyout) then
		if not checkOnly then
			PickupSpellBookItem(flyout, BOOKTYPE_SPELL)
			self:PutToSlot(slot)
		end
		return true
	end
end

function addon:RestoreMount(cache, profile, slot, checkOnly)
	local type = profile.actions[slot][1]
	local id, name, icon

	if type == "summonmount" then
		id, name, icon = unpackByIndex(profile.actions[slot], 5, 6, 8)
	else
		id, name, icon = unpackByIndex(profile.actions[slot], 2, 5, 7)
	end

	local mount = self:GetFromCache(cache, id, name, nil, icon)

	if (mount) then
		if not checkOnly then
			C_MountJournal.Pickup(mount)
			self:PutToSlot(slot)
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
self.db.global.cache = cache

	if profile then
		local slot
		for slot = 1, MAX_ACTION_BUTTONS do
			if not profile.actions[slot] then
				self:ClearSlot(slot, checkOnly)
			else
				local type, id, subType, spellId = unpack(profile.actions[slot])
				local ok

				if type == "spell" then
					ok = self:RestoreSpell(cache.spells, profile, slot, checkOnly)
				elseif type == "flyout" then
					ok = self:RestoreFlyout(cache.flyouts, profile, slot, checkOnly)
				elseif type == "companion" then
					if subType == "MOUNT" then
						ok = self:RestoreMount(cache.mounts, profile, slot, checkOnly)
					end
				elseif type == "summonmount" then
					ok = self:RestoreMount(cache.mounts, profile, slot, checkOnly)
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
				if type == "spell" then
					profile.actions[slot] = { type, id, subType, extraId, GetSpellInfo(id) }

				elseif type == "companion" then
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

				elseif type == "summonmount" then
					local spellId = MOUNT_INDEX_TO_SPELL_ID[id]

					profile.actions[slot] = { type, id, subType, extraId, spellId, GetSpellInfo(spellId) }

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
