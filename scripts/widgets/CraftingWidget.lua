local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")

local CraftingGridItem = require("./widgets/CraftingGridItem")
local Util = require("./Util")

local RECIPE_WIDTH = 200
local RECIPE_HEIGHT = 290
local RECIPE_SPACING = 5

local IMPORTANT_EVENTS = {
    "techtreechange", "itemget", "itemlose", "newactiveitem",
    "stacksizechange", "unlockrecipe", "refreshcrafting", "refreshinventory"
}

local CraftingWidget = Class(Widget, function (self, owner, prefab, closePopup)
    Widget._ctor(self, "CraftingWidget")

    self.prefab = prefab
    self.owner = owner
    self.closePopup = closePopup
    self.needToUpdateRecipes = false
    self.allRecipes = Util:GetAllRecipes(prefab)
    self.root = self:AddChild(Widget("root"))

    Util:Log("recipes count", #self.allRecipes)

    local dialog = self.root:AddChild(Templates.RectangleWindow(890, 500))

    self.grid = dialog:AddChild(Templates.ScrollingGrid(self.allRecipes, {
        scroll_context = {
            screen = self,
        },
        widget_width = RECIPE_WIDTH + RECIPE_SPACING,
        widget_height = RECIPE_HEIGHT + RECIPE_SPACING,
        num_visible_rows = 1.3,
        num_columns = 4,
        item_ctor_fn = function ()
            return CraftingGridItem(owner, closePopup)
        end,
        apply_fn = function (context, gridItem, recipe)
            gridItem:SetRecipe(recipe)
        end,
        scrollbar_offset = 20,
        scrollbar_height_offset = -60
    }))

    self.root:AddChild(Templates.BackButton(closePopup))

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

function CraftingWidget:OnUpdate()
    if self.needToUpdateRecipes then
        Util:Log("updating recipes")

        self.needToUpdateRecipes = false

        self.grid:RefreshView()
    end
end

return CraftingWidget
