local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")
local RecipePopup = require("widgets/recipepopup")
local Image = require("widgets/image")
local Button = require("widgets/button")
local Text = require("widgets/text")
local IngredientUI = require("widgets/ingredientui")

local Util = require("./Util")

local RECIPE_WIDTH = 200
local RECIPE_HEIGHT = 290
local RECIPE_SPACING = 5

local INGREDIENT_SIZE = 55
local INGREDIENT_SPACING = 3

local Ingredient = Class(Widget, function (self, options)
    Widget._ctor(self, "Ingredient")

    local ingredient = options.ingredient
    local prefabName = Util:GetPrefabString(ingredient.type)

    self.root = self:AddChild(Widget("root"))
    self.rootButton = self:AddChild(Button())
    self.ingredientUI = self.rootButton:AddChild(IngredientUI(
        ingredient:GetAtlas(), ingredient:GetImage(), options.needed, options.onHand,
        options.has, prefabName, Util:GetPlayer(), ingredient.type
    ))
    self.ingredientUI:SetScale(0.8, 0.8, 0.8)

    self:SetHoverText(prefabName)

    if options.disabled then
        self.rootButton:Disable()
    end

    self.rootButton:SetOnClick(function ()
        options.chooseItem(ingredient.type)
    end)
end)

return Ingredient
