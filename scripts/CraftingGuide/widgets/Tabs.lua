local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Button = require("widgets/button")

local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

require("constants")
require("strings")

local BUTTON_SETTINGS = {
    {
        width = 60,
        spacing = 4,
        threshold = 5,
    },
    {
        width = 45,
        spacing = 2,
        threshold = 18,
    },
    {
        width = 30,
        spacing = 1,
        threshold = 1e5,
    },
}

--- Tabs
--- @param options.owner            {Player}                      player instance
--- @param options.groups           {RecipeGroup[]}               recipe groups
--- @param options.selectedTabIndex {number}                      selected tab index
--- @param options.switchTab        {(tabIndex: number) => void}  switch tab callbackd
local Tabs = Class(Widget, function (self, options)
    Widget._ctor(self, "Tabs")

    self.owner = options.owner
    self.groups = options.groups
    self.selectedTabIndex = options.selectedTabIndex
    self.switchTab = options.switchTab

    self.itemsInRow = Util:FindIndex(BUTTON_SETTINGS, function (settings)
        return #self.groups <= settings.threshold
    end)

    local buttonSettings = BUTTON_SETTINGS[self.itemsInRow]

    self.buttonSize = buttonSettings.width
    self.buttonSpacing = buttonSettings.spacing

    local buttonsWidth = (self.itemsInRow * self.buttonSize + (self.itemsInRow - 1) * self.buttonSpacing)

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(-buttonsWidth / 2, 0)

    self.tabsWidget = self.root:AddChild(Widget("tabs"))
    self.tabsWidget.tabs = {}

    self:AddTabs()
end)

function Tabs:AddTabs()
    local groupBy = Util:GetSetting(Constants.MOD_OPTIONS.GROUP_BY)

    for i, group in ipairs(self.groups) do
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

        if groupBy == Constants.GROUP_BY_OPTIONS.CRAFTING_TAB then
            local filterDef = Util:Find(CRAFTING_FILTER_DEFS, function (filter)
                return filter.name == group.key
            end)

            if filterDef then
                local filterAtlas = FunctionOrValue(filterDef.atlas, self.owner, filterDef)
                local filterImage = FunctionOrValue(filterDef.image, self.owner, filterDef)

                button.image = button:AddChild(Image(filterAtlas, filterImage))
                button.image:SetScale(self.buttonSize / 300)

                button:SetHoverText(STRINGS.UI.CRAFTING_FILTERS[filterDef.name])
            end
        elseif groupBy == Constants.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE then
            local blueprintTex = (
                group.key == Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.KNOWN_RECIPE
                or group.key == Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.UNKNOWN_RECIPE
            )
                and "blueprint.tex"
                or "blueprint_rare.tex"

            button.image = button:AddChild(Image(Util:GetInventoryItemAtlas(blueprintTex), blueprintTex))
            button.image:SetScale(self.buttonSize / 90)

            local iconTex = group.key == Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.KNOWN_RECIPE
                and "checkmark.tex"
                or group.key == Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.NO_BLUEPRINT
                    and "cross.tex"
                    or "question.tex"

            button.iconImage = button:AddChild(Image(Constants.CUSTOM_ICONS_ATLAS, iconTex))
            button.iconImage:SetScale(self.buttonSize / 150)

            button:SetHoverText(STRINGS.CRAFTING_GUIDE.SETTINGS_CONTENT.GROUP_BY_KNOWLEDGE[group.key])
        end

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
