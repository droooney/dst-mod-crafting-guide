local Widget = require("widgets/widget")
local Screen = require("widgets/screen")
local ImageButton = require("widgets/imagebutton")
local HeaderTabs = require("widgets/redux/headertabs")
local Subscreener = require("screens/redux/subscreener")
local Templates = require("widgets/redux/templates")

local GeneralInfoTab = require("./widgets/GeneralInfoTab")
local RecipesTab = require("./widgets/RecipesTab")

local Constants = require("./Constants")
local Util = require("./Util")

require("constants")

local INITIAL_SCROLL = 1
local INITIAL_TAB_INDEX = 1
-- local DEFAULT_TAB = Constants.TabKey.INFO
local DEFAULT_TAB = Constants.TabKey.RECIPES

--- Root
-- @param owner  {Player}  player instance
-- @param prefab {Prefab}  opened item prefab
local Root = Class(Screen, function (self, owner, prefab)
    Screen._ctor(self, "Root")

    self.root = self:AddChild(Widget("root"))
    self.overlay = self.root:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.dialog = self.root:AddChild(Templates.RectangleWindow(Constants.ITEM_POPUP_WIDTH, Constants.ITEM_POPUP_HEIGHT))
    self.root:AddChild(Templates.BackButton(function () self:NavigateBack() end))

    self.overlay.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.overlay.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.overlay.image:SetVAnchor(ANCHOR_MIDDLE)
    self.overlay.image:SetHAnchor(ANCHOR_MIDDLE)
    self.overlay.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.overlay.image:SetTint(0, 0, 0, 0.5)
    self.overlay:SetOnClick(function () self:Close() end)
    self.overlay:SetHelpTextMessage("")

    -- self.dialog.top:Hide()

    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)

    self.prefabQueue = {}

    self.generalInfoTab = self.dialog:AddChild(GeneralInfoTab())
    self.recipesTab = self.dialog:AddChild(RecipesTab({
        owner = owner,
        prefab = prefab,
        closePopup = function () self:Close() end,
        chooseItem = function (...) self:ChooseItem(...) end,
    }))

    self.subscreener = Subscreener(self, self.BuildTabButtons, {
        [Constants.TabKey.INFO] = self.generalInfoTab,
        [Constants.TabKey.RECIPES] = self.recipesTab,
    })

    self:AddQueueItem(prefab)
end)

function Root:AddQueueItem(prefab)
    table.insert(self.prefabQueue, {
        prefab = prefab,
        activeTab = DEFAULT_TAB,
        scrollY = INITIAL_SCROLL,
        selectedTabIndex = INITIAL_TAB_INDEX,
    })

    self:ChooseUpperQueueItem()
end

function Root:BuildTabButtons(subscreener)
    self.tabButtons = self.dialog:AddChild(subscreener:MenuContainer(HeaderTabs, {
        { key = Constants.TabKey.INFO, text = STRINGS.CRAFTING_GUIDE.TABS.INFO },
        { key = Constants.TabKey.RECIPES, text = STRINGS.CRAFTING_GUIDE.TABS.RECIPES },
    }))

    self.tabButtons:SetPosition(0, Constants.ITEM_POPUP_HEIGHT / 2 + 27)
    self.tabButtons:MoveToBack()

    self.tabButtons:Hide()

    return self.tabButtons.menu
end

function Root:Close()
    TheFrontEnd:PopScreen()
end

function Root:ChooseItem(prefab, scrollYToSave, selectedTabIndex)
    self.prefabQueue[#self.prefabQueue].scrollY = scrollYToSave
    self.prefabQueue[#self.prefabQueue].selectedTabIndex = selectedTabIndex
    self.prefabQueue[#self.prefabQueue].activeTab = self.subscreener.active_key

    self:AddQueueItem(prefab)
end

function Root:ChooseTab(tabKey)
    self.subscreener:OnMenuButtonSelected(tabKey)
end

function Root:ChooseUpperQueueItem()
    local queueItem = self.prefabQueue[#self.prefabQueue]

    self:ChooseTab(queueItem.activeTab)
    self.generalInfoTab:SetPrefab(queueItem.prefab)
    self.recipesTab:SetPrefab(queueItem.prefab, queueItem.scrollY, queueItem.selectedTabIndex)
end

function Root:NavigateBack()
    table.remove(self.prefabQueue)

    if #self.prefabQueue > 0 then
        self:ChooseUpperQueueItem()
    else
        self:Close()
    end
end

function Root:OnControl(control, down)
    if Root._base.OnControl(self, control, down) then
        return true
    end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

        if control == CONTROL_MAP then
            Util:GetPlayer().HUD.controls:ToggleMap()
        else
            self:Close()
        end

        return true
    end

    return false
end

function Root:OnUpdate(...)
    if self.recipesTab and self.recipesTab.OnUpdate then
        self.recipesTab:OnUpdate(...)
    end
end

return Root
