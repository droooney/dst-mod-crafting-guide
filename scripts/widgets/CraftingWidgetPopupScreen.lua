local Widget = require("widgets/widget")
local Screen = require("widgets/screen")
local ImageButton = require("widgets/imagebutton")

local Util = require("./Util")
local CraftingWidget = require("./widgets/CraftingWidget")

require("constants")

local CraftingWidgetPopupScreen = Class(Screen, function (self, owner, prefab)
    Screen._ctor(self, "CraftingWidgetPopupScreen")

    local overlay = self:AddChild(ImageButton("images/global.xml", "square.tex"))

    overlay.image:SetVRegPoint(ANCHOR_MIDDLE)
    overlay.image:SetHRegPoint(ANCHOR_MIDDLE)
    overlay.image:SetVAnchor(ANCHOR_MIDDLE)
    overlay.image:SetHAnchor(ANCHOR_MIDDLE)
    overlay.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    overlay.image:SetTint(0, 0, 0, 0.5)
    overlay:SetOnClick(function ()
        TheFrontEnd:PopScreen()
    end)
    overlay:SetHelpTextMessage("")

    local root = self:AddChild(Widget("root"))

    root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)

    self.prefabQueue = {{
        prefab = prefab,
        scrollY = 0,
    }}

    self.craftingWidget = root:AddChild(CraftingWidget({
        owner = owner,
        prefab = prefab,
        closePopup = function () self:Close() end,
        chooseItem = function (...) self:ChooseItem(...) end,
        navigateBack = function (...) self:NavigateBack(...) end
    }))
end)

function CraftingWidgetPopupScreen:Close()
    TheFrontEnd:PopScreen()
end

function CraftingWidgetPopupScreen:ChooseItem(prefab, scrollYToSave)
    self.prefabQueue[#self.prefabQueue].scrollY = scrollYToSave

    table.insert(self.prefabQueue, {
        prefab = prefab,
        scrollY = 1,
    })

    self.craftingWidget:SetPrefab(prefab, 1)
end

function CraftingWidgetPopupScreen:NavigateBack()
    table.remove(self.prefabQueue)

    if #self.prefabQueue > 0 then
        local queueItem = self.prefabQueue[#self.prefabQueue]

        self.craftingWidget:SetPrefab(queueItem.prefab, queueItem.scrollY)
    else
        self:Close()
    end
end

function CraftingWidgetPopupScreen:OnControl(control, down)
    if CraftingWidgetPopupScreen._base.OnControl(self, control, down) then
        return true
    end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Close()

        return true
    end

    return false
end

function CraftingWidgetPopupScreen:OnUpdate()
    if self.craftingWidget and self.craftingWidget.OnUpdate then
        self.craftingWidget:OnUpdate()
    end
end

return CraftingWidgetPopupScreen
