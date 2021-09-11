local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Button = require("widgets/button")

local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

require("strings")

local ITEMS_IN_ROW = 2
local BUTTON_WIDTH = 45
local BUTTON_HEIGHT = 45
local BUTTON_SPACING = 2

--- Tabs
-- @param options.owner             {Player}                      player instance
-- @param options.tabs              {RecipeTab[]}                 tabs array
-- @param options.selectedTabIndex  {number}                      selected tab index
-- @param options.switchTab         {(tabIndex: number) => void}  switch tab callbackd
local Tabs = Class(Widget, function (self, options)
    Widget._ctor(self, "Tabs")

    self.owner = options.owner
    self.tabs = options.tabs
    self.selectedTabIndex = options.selectedTabIndex
    self.switchTab = options.switchTab

    self.root = self:AddChild(Widget("root"))
    self.tabsWidget = self.root:AddChild(Widget("tabs"))

    self.tabsWidget.tabs = {}

    self:AddTabs()
end)

function Tabs:AddTabs(tabs)
    for i, tab in ipairs(self.tabs) do
        local j = i - 1
        local button = self.tabsWidget:AddChild(Button())

        table.insert(self.tabsWidget.tabs, button)

        button:SetPosition(
            (j % ITEMS_IN_ROW) * (BUTTON_WIDTH + BUTTON_SPACING),
            -math.floor(j / ITEMS_IN_ROW) * (BUTTON_HEIGHT + BUTTON_SPACING)
        )

        button.defaultBg = button:AddChild(Image("images/hud.xml", "craft_slot.tex"))
        button.defaultBg:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)

        button.selectedBg = button:AddChild(Image("images/hud.xml", "craft_slot_place.tex"))
        button.selectedBg:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)

        button.image = button:AddChild(Image(tab.icon_atlas or "images/hud.xml", tab.icon))
        button.image:SetScale(0.3)
        button.image:SetPosition(-4, 0)

        button:SetHoverText(STRINGS.TABS[tab.str])

        button:SetOnClick(function ()
            self:SelectTab(i)
            self.switchTab(i)
        end)

        if i == self.selectedTabIndex then
            button:Disable()
            button.defaultBg:Hide()
        else
            button.selectedBg:Hide()
        end
    end
end

function Tabs:SelectTab(index)
    local prevActiveTab = self.tabsWidget.tabs[self.selectedTabIndex]
    local newActiveTab = self.tabsWidget.tabs[index]

    prevActiveTab:Enable()
    prevActiveTab.selectedBg:Hide()
    prevActiveTab.defaultBg:Show()

    newActiveTab:Disable()
    newActiveTab.selectedBg:Show()
    newActiveTab.defaultBg:Hide()

    self.selectedTabIndex = index
end

return Tabs
