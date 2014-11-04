local MAJOR, MINOR = "S2KTools-1.0", 1

local lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local DEFAULT_PAPERDOLL_NUM_TABS = 3

function unpackByIndex(tab, ...)
	local indexes, res = {...}, {}

	local i, j = 0
	for _, j in pairs(indexes) do
		i = i + 1
		res[i] = tab[j]
	end

	return unpack(res, 1, i)
end

function lib:InjectPaperDollSidebarTab(name, frame, icon, texCoords)
	local tabIndex = #PAPERDOLL_SIDEBARS + 1
	local extraTabs = tabIndex - DEFAULT_PAPERDOLL_NUM_TABS

	PAPERDOLL_SIDEBARS[tabIndex] = { name = name, frame = frame, icon = icon, texCoords = texCoords }

	local tabButton = CreateFrame(
		"Button", "PaperDollSidebarTab" .. tabIndex, PaperDollSidebarTabs,
		"PaperDollSidebarTabTemplate", tabIndex
	)

	tabButton:SetPoint("BOTTOMRIGHT", (extraTabs < 2 and -30) or (extraTabs < 3 and -10) or 0, 0)

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
					CharacterLevelText:SetPoint(
						point, relativeTo, relativePoint,
						xOffset - (20 + 10 * extraTabs), yOffset
					)
				end
			end
		end
	end
end

local function HookPetJournal()
	local saved = { search = "" }

	hooksecurefunc(C_PetJournal, "ClearSearchFilter", function() saved.search = "" end)
	hooksecurefunc(C_PetJournal, "SetSearchFilter", function(text) saved.search = text end)

	C_PetJournal.GetSearchFilter = function() return saved.search end
end

if not oldMinor then
	HookPetJournal()
end
