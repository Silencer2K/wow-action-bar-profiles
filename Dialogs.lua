local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local DEBUG = "|cffff0000Debug:|r "

StaticPopupDialogs.CONFIRM_USE_ACTION_BAR_PROFILE = {
    text = L.confirm_use,

    button1 = YES,
    button2 = NO,

    OnAccept = function(popup) addon:OnUseConfirm(popup) end,
    OnHide = function(popup) end,
    OnCancel = function(popup) end,

    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}

StaticPopupDialogs.CONFIRM_DELETE_ACTION_BAR_PROFILE = {
    text = L.confirm_delete,

    button1 = YES,
    button2 = NO,

    OnAccept = function(popup) addon:OnDeleteConfirm(popup) end,
    OnHide = function(popup) end,
    OnCancel = function(popup) end,

    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}

StaticPopupDialogs.CONFIRM_SAVE_ACTION_BAR_PROFILE = {
    text = L.confirm_save,

    button1 = YES,
    button2 = NO,

    OnAccept = function(popup) addon:OnSaveConfirm(popup) end,
    OnHide = function(popup) end,
    OnCancel = function(popup) end,

    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}

StaticPopupDialogs.CONFIRM_OVERWRITE_ACTION_BAR_PROFILE = {
    text = L.confirm_overwrite,

    button1 = YES,
    button2 = NO,

    OnAccept = function(popup) addon:OnOverwriteConfirm(popup) end,
    OnHide = function(popup) end,
    OnCancel = function(popup) end,

    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}

StaticPopupDialogs.CONFIRM_RECEIVE_ACTION_BAR_PROFILE = {
    text = L.confirm_receive,

    button1 = YES,
    button2 = NO,

    OnAccept = function(popup) addon:OnReceiveConfirm(popup) end,
    OnHide = function(popup) end,
    OnCancel = function(popup) end,

    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}

function addon:ShowPopup(id, p1, p2, options)
    local popup = StaticPopup_Show(id, p1, p2)
    if popup then
        if options then
            local k, v
            for k, v in pairs(options) do
                popup[k] = v
            end
        end

        return popup
    end
end

function addon:OnUseConfirm(popup)
    addon:UseProfile(popup.name)
end

function addon:OnDeleteConfirm(popup)
    addon:DeleteProfile(popup.name)
end

function addon:OnSaveConfirm(popup)
    addon:UpdateProfile(popup.name)
end

function addon:OnOverwriteConfirm(popup)
    addon:SaveProfile(popup.name, popup.options)

    if popup.hide then
        popup.hide:Hide()
    end
end

function addon:OnReceiveConfirm(popup)
    local name = self:GuessName(popup.name)
    if name then
        local list = self.db.profile.list

        list[name] = popup.profile

        self:UpdateGUI()
        self:Printf(L.msg_profile_saved, name)
    end
end
