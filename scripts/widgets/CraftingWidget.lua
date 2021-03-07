local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")

local RecipeWidget = require("./widgets/RecipeWidget")

local Constants = require("./Constants")
local Util = require("./Util")

require("constants")

local RECIPE_WIDTH = 200
local RECIPE_HEIGHT = 290
local RECIPE_SPACING = 5

local IMPORTANT_EVENTS = {
    "techtreechange", "itemget", "itemlose", "newactiveitem",
    "stacksizechange", "unlockrecipe", "refreshcrafting", "refreshinventory"
}

--- CraftingWidget
-- @param options.owner        {Player}                                     player instance
-- @param options.prefab       {Prefab}                                     opened item prefab
-- @param options.chooseItem   {(prefab: Prefab, scrollY: number) => void}  choose item callback
-- @param options.navigateBack {() => void}                                 navigate to prev page
-- @param options.closePopup   {() => void}                                 close item popup
local CraftingWidget = Class(Widget, function (self, options)
    Widget._ctor(self, "CraftingWidget")

    local owner = options.owner
    local prefab = options.prefab

    self.prefab = prefab
    self.owner = options.owner
    self.chooseItem = options.chooseItem
    self.needToUpdateRecipes = false
    self.root = self:AddChild(Widget("root"))

    self:SetRecipes()

    Util:Log("recipes count for " .. prefab .. ": " .. #self.allRecipes)

    local dialog = self.root:AddChild(Templates.RectangleWindow(Constants.ITEM_POPUP_WIDTH, Constants.ITEM_POPUP_HEIGHT))

    self.grid = dialog:AddChild(Templates.ScrollingGrid(self.allRecipes, {
        widget_width = Constants.RECIPE_WIDTH + Constants.RECIPE_SPACING,
        widget_height = Constants.RECIPE_HEIGHT + Constants.RECIPE_SPACING,
        num_visible_rows = Constants.VISIBLE_RECIPES,
        num_columns = Constants.RECIPES_COLUMNS_COUNT,
        item_ctor_fn = function ()
            return RecipeWidget({
                owner = owner,
                closePopup = options.closePopup,
                chooseItem = function (...) self:ChooseItem(...) end,
            })
        end,
        apply_fn = function (context, recipeWidget, recipeData)
            recipeWidget:SetRecipeData(recipeData)
        end,
        scrollbar_offset = (Constants.ITEM_POPUP_WIDTH - Constants.SCROLL_LIST_WIDTH) / 2,
        scrollbar_height_offset = -60
    }))

    self.root:AddChild(Templates.BackButton(options.navigateBack))

    local lastHealthSeg = nil
    local lastHealthPenaltySeg = nil
    local lastSanitySeg = nil
    local lastSanityPenaltySeg = nil

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
end)

function CraftingWidget:ChooseItem(prefab)
    self.chooseItem(prefab, self.grid.current_scroll_pos)
end

function CraftingWidget:SetRecipes()
    local recipes = Util:GetAllRecipes(self.prefab)

    self.allRecipes = {}

    for _, recipe in ipairs(recipes) do
        table.insert(self.allRecipes, {
            recipe = recipe,
            pagePrefab = self.prefab,
        })
    end
end

function CraftingWidget:SetPrefab(prefab, scrollY)
    self.prefab = prefab

    self:SetRecipes()

    Util:Log("recipes count for " .. prefab .. ": " .. #self.allRecipes)

    self.grid:SetItemsData(self.allRecipes)

    self.grid.target_scroll_pos = scrollY
    self.grid.current_scroll_pos = scrollY

    self.grid:RefreshView()
end

function CraftingWidget:OnUpdate()
    if self.needToUpdateRecipes then
        Util:Log("updating recipes")

        self.needToUpdateRecipes = false

        self.grid:RefreshView()
    end
end

return CraftingWidget
