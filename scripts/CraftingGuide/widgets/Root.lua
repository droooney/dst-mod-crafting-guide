local Widget = require("widgets/widget")
local Screen = require("widgets/screen")
local ImageButton = require("widgets/imagebutton")
local HeaderTabs = require("widgets/redux/headertabs")
local Subscreener = require("screens/redux/subscreener")
local Templates = require("widgets/redux/templates")

local GeneralInfoTab = require("CraftingGuide/widgets/GeneralInfoTab")
local RecipesTab = require("CraftingGuide/widgets/RecipesTab")

local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

require("constants")

local INITIAL_SCROLL = 1
local INITIAL_TAB_INDEX = 1
-- local DEFAULT_TAB = Constants.TabKey.INFO
local DEFAULT_TAB = Constants.TabKey.RECIPES

--- Root
--- @param owner  {Player}  player instance
--- @param prefab {Prefab}  opened item prefab
local Root = Class(Screen, function (self, owner, prefab)
    Screen._ctor(self, "Root")

    self.root = self:AddChild(Widget("root"))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)

    self.overlay = self.root:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.overlay.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.overlay.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.overlay.image:SetVAnchor(ANCHOR_MIDDLE)
    self.overlay.image:SetHAnchor(ANCHOR_MIDDLE)
    self.overlay.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.overlay.image:SetTint(0, 0, 0, 0.5)
    self.overlay:SetOnClick(function () self:Close() end)
    self.overlay:SetHelpTextMessage("")

    self.dialog = self.root:AddChild(Templates.RectangleWindow(Constants.ITEM_POPUP_WIDTH, Constants.ITEM_POPUP_HEIGHT))
    -- self.dialog.top:Hide()

    self.root:AddChild(Templates.BackButton(function () self:NavigateBack() end))

    self.prefabHistory = {}
    self.settingsOpened = false

    self.generalInfoTab = self.dialog:AddChild(GeneralInfoTab())
    self.recipesTab = self.dialog:AddChild(RecipesTab({
        owner = owner,
        prefab = prefab,
        closePopup = function () self:Close() end,
        chooseItem = function (...) self:ChooseItem(...) end,
        resetValuesInHistory = function () self:ResetValuesInHistory() end,
    }))

    self.subscreener = Subscreener(self, self.BuildTabButtons, {
        [Constants.TabKey.INFO] = self.generalInfoTab,
        [Constants.TabKey.RECIPES] = self.recipesTab,
    })

    self:AddHistoryItem(prefab)
end)

function Root:AddHistoryItem(prefab)
    table.insert(self.prefabHistory, {
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
    Util:SaveSettings()
    TheFrontEnd:PopScreen()
end

function Root:ChooseItem(prefab, scrollYToSave, selectedTabIndex)
    self.prefabHistory[#self.prefabHistory].scrollY = scrollYToSave
    self.prefabHistory[#self.prefabHistory].selectedTabIndex = selectedTabIndex
    self.prefabHistory[#self.prefabHistory].activeTab = self.subscreener.active_key

    self:AddHistoryItem(prefab)
end

function Root:ChooseTab(tabKey)
    self.subscreener:OnMenuButtonSelected(tabKey)
end

function Root:ChooseUpperQueueItem()
    local historyItem = self.prefabHistory[#self.prefabHistory]

    self:ChooseTab(historyItem.activeTab)
    self.generalInfoTab:SetPrefab(historyItem.prefab)
    self.recipesTab:SetPrefab(historyItem.prefab, historyItem.scrollY, historyItem.selectedTabIndex)
end

function Root:NavigateBack()
    if self:TryRecipesBack() then
        return
    end

    table.remove(self.prefabHistory)

    if #self.prefabHistory > 0 then
        self:ChooseUpperQueueItem()
    else
        self:Close()
    end
end

function Root:TryRecipesBack()
    local historyItem = self.prefabHistory[#self.prefabHistory]

    return historyItem.activeTab == Constants.TabKey.RECIPES and self.recipesTab:NavigateBack()
end

function Root:ResetValuesInHistory()
    for _, historyItem in ipairs(self.prefabHistory) do
        historyItem.scrollY = INITIAL_SCROLL
        historyItem.selectedTabIndex = INITIAL_TAB_INDEX
    end

    self:ChooseUpperQueueItem()
end

function Root:OnControl(control, down)
    if Root._base.OnControl(self, control, down) then
        return true
    end

    if down or (control ~= CONTROL_MAP and control ~= CONTROL_CANCEL) then
        return false
    end

    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

    if control == CONTROL_MAP then
        Util:GetPlayer().HUD.controls:ToggleMap()
    elseif not self:TryRecipesBack() then
        self:Close()
    end

    return true
end

function Root:OnUpdate(...)
    if self.recipesTab and self.recipesTab.OnUpdate then
        self.recipesTab:OnUpdate(...)
    end
end

return Root
