local saved

local function HookPetJournal()
	saved = { search = "" }
	
	hooksecurefunc(C_PetJournal, "ClearSearchFilter", function()
		saved.search = ""
	end)

	hooksecurefunc(C_PetJournal, "SetSearchFilter", function(text)
		saved.search = text
	end)

	C_PetJournal.GetSearchFilter = function()
		return saved.search
	end
end

HookPetJournal()
