local InvSlot = require("widgets/invslot")
local LocoMotor = require("components/locomotor")

local CraftingWidgetPopupScreen = require("./widgets/CraftingWidgetPopupScreen")
local Util = require("./Util")

--local oldInvSlotInspect = InvSlot.Inspect
--
--function InvSlot:Inspect()
----    oldInvSlotInspect(self)
--
--    if self.tile and self.tile.item then
--        Util:Log("inspecting item: "..self.tile.item.prefab)
--        Util:GetPlayer().HUD:OpenScreenUnderPause(CraftingWidgetPopupScreen())
--    end
--end

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
            Util:GetPlayer().HUD:OpenScreenUnderPause(CraftingWidgetPopupScreen(target.prefab))
        end)
    end
end
