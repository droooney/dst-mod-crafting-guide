local Root = require("./widgets/Root")
local Constants = require("./Constants")
local Util = require("./Util")

require("./i18n/common")
require("./i18n/en")

local SUPPORTED_LANGUAGES = {
    en = true,
    ru = true,
}

function LoadI18N()
    local lang = GLOBAL.LanguageTranslator.defaultlang or nil

    if lang and SUPPORTED_LANGUAGES[lang] then
        require("./i18n/" .. lang)
    end
end

Assets = {
    Asset("ATLAS", "images/icons.xml"),
}

AddClassPostConstruct("widgets/controls", function ()
    LoadI18N()

    local InvSlot = require("widgets/invslot")

    function InvSlot:Inspect(item)
        local item = self.tile.item

        if item and item.prefab then
            Util:Log("inspecting item from inventory: " .. item.prefab)

            self.inst:DoTaskInTime(0, function ()
                Util:GetPlayer().HUD:OpenScreenUnderPause(Root(Util:GetPlayer(), item.prefab))
                self:ClearFocus()
            end)
        end
    end
end)
