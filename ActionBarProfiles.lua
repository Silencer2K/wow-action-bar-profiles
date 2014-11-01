local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

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

function addon:UseProfile(name)
	local profiles = self.db.global.profiles or {}
	local profile = profiles[name]

	if profile then
	end
end

function addon:SaveProfile(name)
	local profiles = self.db.global.profiles or {}

	profiles[name] = { name = name }

	self:UpdateProfileParams(name)
	self:UpdateProfileBars(name)
end

function addon:DeleteProfile(name)
	local profiles = self.db.global.profiles or {}

	profiles[name] = nil
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
	end
end
