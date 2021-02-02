local CraftingWidgetPopupScreen = require("./widgets/CraftingWidgetPopupScreen")
local Constants = require("./Constants")
local Util = require("./Util")

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

-- TODO: find out why doesn't work in standard world
AddClassPostConstruct("widgets/controls", function ()
    LoadI18N()

    local LocoMotor = require("components/locomotor")
    local oldLocoMotorPushAction = LocoMotor.PushAction

    function LocoMotor:PushAction(bufferedaction, ...)
        if bufferedaction.action ~= GLOBAL.ACTIONS.LOOKAT then
            oldLocoMotorPushAction(self, bufferedaction, ...)

            return
        end

        local target = bufferedaction.target or bufferedaction.invobject

        if target and target.prefab then
            Util:Log("inspecting item: " .. target.prefab)

            self.inst:DoTaskInTime(0, function ()
                Util:GetPlayer().HUD:OpenScreenUnderPause(CraftingWidgetPopupScreen(Util:GetPlayer(), target.prefab))
            end)
        end
    end
end)
