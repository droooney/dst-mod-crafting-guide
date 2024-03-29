local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

local Root = require("CraftingGuide/widgets/Root")

require("CraftingGuide/i18n/common")
require("CraftingGuide/i18n/en")

require("strings")

local SUPPORTED_LANGUAGES = {"en", "ru"}

function LoadI18N()
    local lang = GLOBAL.LanguageTranslator.defaultlang or nil

    if Util:Includes(SUPPORTED_LANGUAGES, lang) then
        require("CraftingGuide/i18n/" .. lang)
    end
end

Assets = {
    Asset("ATLAS", "images/CraftingGuide/icons.xml"),
}

AddClassPostConstruct("widgets/controls", function ()
    LoadI18N()

    local InvSlot = require("widgets/invslot")

    function InvSlot:Inspect()
        local item = self.tile and self.tile.item

        if item and item.prefab then
            self.inst:DoTaskInTime(0, function ()
                Util:GetPlayer().HUD:OpenScreenUnderPause(Root(Util:GetPlayer(), Util:GetItemPrefab(item)))
                self:ClearFocus()
            end)
        end
    end

    Util:SetKeyBinding(Constants.MOD_OPTIONS.KEY_OPEN_ALL, function ()
        local activeScreen = GLOBAL.TheFrontEnd:GetActiveScreen()

        if activeScreen and activeScreen.name == "HUD" then
            Util:GetPlayer().HUD:OpenScreenUnderPause(Root(Util:GetPlayer()))
        end
    end)
end)

AddClassPostConstruct("screens/playerhud", function (self)
    local oldIsCraftingOpen = self.IsCraftingOpen

    function self:IsCraftingOpen(...)
        if Util:IsWidgetOpen() then
            return true
        end

        return oldIsCraftingOpen(self,...)
    end
end)

AddClassPostConstruct("cameras/followcamera", function (self)
    local oldCanControl = self.CanControl
    local oldIsControllable = self.IsControllable

    function self:CanControl(...)
        if Util:IsWidgetOpen() then
            return false
        end

        return oldCanControl(self,...)
    end

    function self:IsControllable(...)
        if Util:IsWidgetOpen() then
            return false
        end

        return oldIsControllable(self,...)
    end
end)

local settings = {}

for _, paramName in pairs(Constants.MOD_OPTIONS) do
    settings[paramName] = GetModConfigData(paramName)
end

Util:SetGlobal(GLOBAL)
Util:SetModName(modname)
Util:SetSettings(settings)
