local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")

local Recipe = require("CraftingGuide/widgets/Recipe")
local Settings = require("CraftingGuide/widgets/Settings")
local Tabs = require("CraftingGuide/widgets/Tabs")

local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

require("constants")
require("strings")

local IMPORTANT_EVENTS = {
    "techtreechange", "itemget", "itemlose", "newactiveitem",
    "stacksizechange", "unlockrecipe", "refreshcrafting", "refreshinventory"
}

--- RecipesTab
--- ChooseItem {(prefab: Prefab, scrollY: number, selectedTabIndex: number) => void}
--- @param options.owner                {Player}       player instance
--- @param options.prefab               {Prefab | nil} opened item prefab
--- @param options.chooseItem           {ChooseItem}   choose item callback
--- @param options.closePopup           {() => void}   close item popup
--- @param options.resetValuesInHistory {() => void}   reset scroll/tab values in history
local RecipesTab = Class(Widget, function (self, options)
    Widget._ctor(self, "RecipesTab")

    local owner = options.owner

    self.owner = options.owner
    self.chooseItem = options.chooseItem
    self.closePopup = options.closePopup
    self.resetValuesInHistory = options.resetValuesInHistory
    self.needToUpdateRecipes = false
    self.settingsOpened = false
    self.settings = Util:GetSettings()
    self.prefab = options.prefab
    self.selectedTabIndex = 1
    self.allRecipes = {}
    self.skins = {}

    self.root = self:AddChild(Widget("root"))
    self.tabContent = self.root:AddChild(Widget("tabContent"))
    self.settingsContent = self.root:AddChild(Settings("settingsContent"))

    self.settingsButton = self.tabContent:AddChild(ImageButton())
    self.settingsButton:SetText(STRINGS.CRAFTING_GUIDE.SETTINGS)
    self.settingsButton:SetOnClick(function () self:ShowSettingsContent() end)
    self.settingsButton:SetScale(0.6)
    self.settingsButton:SetPosition(-400, -220)

    local lastHealthSeg
    local lastHealthPenaltySeg
    local lastSanitySeg
    local lastSanityPenaltySeg

    local function OnHealthDeltaChange(owner, data)
        local health = owner.replica.health

        if health then
            local currentSeg = math.floor(math.ceil(data.newpercent * health:Max()) / CHARACTER_INGREDIENT_SEG)
            local penaltySeg = health:GetPenaltyPercent()

            if currentSeg ~= lastHealthSeg or penaltySeg ~= lastHealthPenaltySeg then
                lastHealthSeg = currentSeg
                lastHealthPenaltySeg = penaltySeg
                self.needToUpdateRecipes = true
            end
        end
    end

    local function OnSanityDeltaChange(owner, data)
        local sanity = owner.replica.sanity

        if sanity then
            local currentSeg = math.floor(math.ceil(data.newpercent * sanity:Max()) / CHARACTER_INGREDIENT_SEG)
            local penaltySeg = sanity:GetPenaltyPercent()

            if currentSeg ~= lastSanitySeg or penaltySeg ~= lastSanityPenaltySeg then
                lastSanitySeg = currentSeg
                lastSanityPenaltySeg = penaltySeg
                self.needToUpdateRecipes = true
            end
        end
    end

    self.inst:ListenForEvent("healthdelta", OnHealthDeltaChange, owner)
    self.inst:ListenForEvent("sanitydelta", OnSanityDeltaChange, owner)

    for _, event in ipairs(IMPORTANT_EVENTS) do
        self.inst:ListenForEvent(event, function () self.needToUpdateRecipes = true end, owner)
    end

    self:ShowTabContent()
end)

function RecipesTab:CreateTabs()
    if self.tabs then
        self.tabs:Kill()
    end

    if Util:GetSetting(Constants.MOD_OPTIONS.GROUP_BY) == Constants.GROUP_BY_OPTIONS.NONE then
        return
    end

    self.tabs = self.tabContent:AddChild(Tabs({
        owner = self.owner,
        groups = self.allRecipes,
        selectedTabIndex = self.selectedTabIndex,
        switchTab = function (...) self:SwitchTab(...) end,
    }))

    self.tabs:SetPosition(-402, 227)
end

function RecipesTab:CreateGrid()
    local recipes = self.allRecipes[self.selectedTabIndex].recipes

    self.grid = self.tabContent:AddChild(Templates.ScrollingGrid(recipes, {
        widget_width = Constants.RECIPE_WIDTH + Constants.RECIPE_SPACING,
        widget_height = Constants.RECIPE_HEIGHT + Constants.RECIPE_SPACING,
        num_visible_rows = #recipes > 3
            and Constants.VISIBLE_RECIPES_MORE_ROWS
            or Constants.VISIBLE_RECIPES_ONE_ROW,
        num_columns = Constants.RECIPES_COLUMNS_COUNT,
        item_ctor_fn = function ()
            return Recipe({
                owner = self.owner,
                skins = self.skins,
                pagePrefab = self.prefab,
                closePopup = self.closePopup,
                chooseItem = function (...) self:ChooseItem(...) end,
                chooseSkin = function (...) self:ChooseSkin(...) end,
            })
        end,
        apply_fn = function (_, recipeWidget, recipe)
            recipeWidget:SetRecipeData(recipe)
        end,
        scrollbar_offset = 70,
        scrollbar_height_offset = -60,
    }))

    self.grid:SetItemsData(recipes)
end

function RecipesTab:ShowRecipes()
    if self.grid then
        self.grid:Kill()

        self.grid = nil
    end

    if self.noRecipes then
        self.noRecipes:Kill()
    end

    if #self.allRecipes == 0 then
        self.noRecipes = self.tabContent:AddChild(Text(NEWFONT, 60, STRINGS.CRAFTING_GUIDE.NO_RECIPES))
    else
        self:CreateGrid()
    end
end

function RecipesTab:SwitchTab(tabIndex)
    self.selectedTabIndex = tabIndex

    self:ShowRecipes()
end

function RecipesTab:ChooseItem(prefab)
    self.chooseItem(prefab, self.grid.current_scroll_pos, self.selectedTabIndex)
end

function RecipesTab:ChooseSkin(itemPrefab, skinPrefab)
    self.skins[itemPrefab] = skinPrefab
end

function RecipesTab:SetPrefab(prefab, scrollY, selectedTabIndex)
    self.prefab = prefab
    self.selectedTabIndex = selectedTabIndex
    self.allRecipes = Util:GetAllRecipesGrouped(prefab)
    self.skins = {}

    self:CreateTabs()
    self:ShowRecipes()

    if self.grid then
        self.grid.target_scroll_pos = scrollY
        self.grid.current_scroll_pos = scrollY

        self.grid:RefreshView()
    end
end

function RecipesTab:ShowSettingsContent()
    self.settingsOpened = true

    self.settingsContent:Show()
    self.tabContent:Hide()
end

function RecipesTab:ShowTabContent()
    self.settingsOpened = false

    self.tabContent:Show()
    self.settingsContent:Hide()
end

function RecipesTab:NavigateBack()
    if not self.settingsOpened then
        return false
    end

    self:ShowTabContent()

    if Util:HaveSettingsChanged(self.settings) then
        self.resetValuesInHistory()
    end

    self.settings = Util:GetSettings()

    return true
end

function RecipesTab:OnUpdate()
    if self.needToUpdateRecipes then
        self.needToUpdateRecipes = false

        if self.grid then
            self.grid:RefreshView()
        end
    end
end

return RecipesTab
