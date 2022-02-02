local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Button = require("widgets/button")

local Util = require("CraftingGuide/Util")

require("constants")
require("strings")

local BUTTON_SETTINGS = {
    {
        width = 60,
        spacing = 4,
        imageShift = -6,
        threshold = 5,
    },
    {
        width = 45,
        spacing = 2,
        imageShift = -4,
        threshold = 18,
    },
    {
        width = 30,
        spacing = 1,
        imageShift = -2,
        threshold = 1e5,
    },
}

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

    self.itemsInRow = Util:FindIndex(BUTTON_SETTINGS, function (settings)
        return #self.tabs <= settings.threshold
    end)

    local buttonSettings = BUTTON_SETTINGS[self.itemsInRow]

    self.buttonSize = buttonSettings.width
    self.buttonSpacing = buttonSettings.spacing
    self.imageShift = buttonSettings.imageShift

    local buttonsWidth = (self.itemsInRow * self.buttonSize + (self.itemsInRow - 1) * self.buttonSpacing)

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(-buttonsWidth / 2, 0)

    self.tabsWidget = self.root:AddChild(Widget("tabs"))
    self.tabsWidget.tabs = {}

    self:AddTabs()
end)

function Tabs:AddTabs()
    for i, tab in ipairs(self.tabs) do
        local j = i - 1
        local button = self.tabsWidget:AddChild(Button())

        table.insert(self.tabsWidget.tabs, button)

        button:SetPosition(
            (j % self.itemsInRow) * (self.buttonSize + self.buttonSpacing) + self.buttonSize / 2,
            -math.floor(j / self.itemsInRow) * (self.buttonSize + self.buttonSpacing) - self.buttonSize / 2
        )

        button.defaultBg = button:AddChild(Image("images/hud.xml", "craft_slot.tex"))
        button.defaultBg:SetSize(self.buttonSize, self.buttonSize)

        button.selectedBg = button:AddChild(Image("images/hud.xml", "craft_slot_place.tex"))
        button.selectedBg:SetSize(self.buttonSize, self.buttonSize)

        button.image = button:AddChild(Image(tab.icon_atlas or "images/hud.xml", tab.icon))
        button.image:SetScale(self.buttonSize / 150)
        button.image:SetPosition(self.imageShift, 0)

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
