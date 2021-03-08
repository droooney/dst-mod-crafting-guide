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
    Asset("ATLAS", Constants.CUSTOM_ICONS_ATLAS),
}

AddClassPostConstruct("widgets/controls", function ()
    LoadI18N()

    local InventoryReplica = require("components/inventory_replica")

    function InventoryReplica:InspectItemFromInvTile(item)
        if item and item.prefab then
            Util:Log("inspecting item from inventory: " .. item.prefab)

            self.inst:DoTaskInTime(0, function ()
                Util:GetPlayer().HUD:OpenScreenUnderPause(Root(Util:GetPlayer(), item.prefab))
            end)
        end
    end
end)
