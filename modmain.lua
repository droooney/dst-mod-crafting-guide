local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

local Root = require("CraftingGuide/widgets/Root")

require("CraftingGuide/i18n/common")
require("CraftingGuide/i18n/en")

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
            Util:Log("inspecting item from inventory: " .. item.prefab)

            self.inst:DoTaskInTime(0, function ()
                Util:GetPlayer().HUD:OpenScreenUnderPause(Root(Util:GetPlayer(), item.prefab))
                self:ClearFocus()
            end)
        end
    end
end)

local settings = {}

for _, paramName in pairs(Constants.MOD_OPTIONS) do
    settings[paramName] = GetModConfigData(paramName)
end

Util:SetModName(modname)
Util:SetSettings(settings)
