local Root = require("CraftingGuide/widgets/Root")
local Util = require("CraftingGuide/Util")

require("CraftingGuide/i18n/common")
require("CraftingGuide/i18n/en")

local SUPPORTED_LANGUAGES = {
    en = true,
    ru = true,
}

function LoadI18N()
    local lang = GLOBAL.LanguageTranslator.defaultlang or nil

    if lang and SUPPORTED_LANGUAGES[lang] then
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
