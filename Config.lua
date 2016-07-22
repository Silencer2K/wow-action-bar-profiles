local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:GetOptions()
    return {
        type = 'group',
        args = {
            general = {
                name = L.settings,
                type = 'group',
                args = {
                    minimap = {
                        name = L.minimap_icon,
                        -- desc = L.minimap_icon_desc,
                        type = 'toggle',
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
                },
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
        },
    }
end
