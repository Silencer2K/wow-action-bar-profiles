local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:GetOptions()
    self.options = self.options or {
        type = "group",
        args = {
            general = {
                name = L.cfg_settings,
                type = "group",
                args = {
                    minimap = {
                        order = 1,
                        name = L.cfg_minimap_icon,
                        type = "toggle",
                        width = "full",
                        set = function(info, value)
                            self.db.profile.minimap.hide = not value
                            if value then
                                self.icon:Show(addonName)
                            else
                                self.icon:Hide(addonName)
                            end
                        end,
                        get = function(info)
                            return not self.db.profile.minimap.hide
                        end,
                    },
                    delete_macros = {
                        order = 2,
                        name = L.cfg_delete_macros,
                        type = "toggle",
                        width = "full",
                        set = function(info, value)
                            self.db.profile.delete_macros = value
                        end,
                        get = function(info)
                            return self.db.profile.delete_macros
                        end,
                    },
                },
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
        },
    }
    return self.options
end
