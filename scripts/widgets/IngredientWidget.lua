local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")
local RecipePopup = require("widgets/recipepopup")
local Image = require("widgets/image")
local Text = require("widgets/text")
local IngredientUI = require("widgets/ingredientui")

local Util = require("./Util")

local RECIPE_WIDTH = 200
local RECIPE_HEIGHT = 290
local RECIPE_SPACING = 5

local INGREDIENT_SIZE = 55
local INGREDIENT_SPACING = 3

local IngredientWidget = Class(Widget, function (self, ingredient, needed, onHand, has)
    Widget._ctor(self, "IngredientWidget")

    local prefabName = Util:GetPrefabString(ingredient.type)

    self.root = self:AddChild(Widget("root"))
    self.ingredientUI = self.root:AddChild(IngredientUI(
        ingredient:GetAtlas(), ingredient:GetImage(), needed, onHand,
        has, prefabName, Util:GetPlayer(), ingredient.type
    ))
    self.ingredientUI:SetScale(0.8, 0.8, 0.8)

    self:SetHoverText(prefabName)
end)

return IngredientWidget
