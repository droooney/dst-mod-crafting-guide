local Widget = require("widgets/widget")
local Button = require("widgets/button")
local IngredientUI = require("widgets/ingredientui")

local Util = require("CraftingGuide/Util")

--- Ingredient
--- @param options.ingredient {Ingredient}                ingredient instance
--- @param options.needed     {number | nil}              needed amount
--- @param options.onHand     {number | nil}              amount on hand
--- @param options.has        {boolean}                   if amount is enough
--- @param options.disabled   {boolean}                   is button disabled
--- @param options.chooseItem {(prefab: Prefab) => void}  choose item callback
local Ingredient = Class(Widget, function (self, options)
    Widget._ctor(self, "Ingredient")

    local ingredient = options.ingredient
    local prefabName = Util:GetPrefabString(ingredient.type)

    self.root = self:AddChild(Widget("root"))
    self.rootButton = self:AddChild(Button())
    self.ingredientUI = self.rootButton:AddChild(IngredientUI(
        ingredient:GetAtlas(), ingredient:GetImage(), options.needed ~= 0 and options.needed or nil, options.onHand,
        options.has, prefabName, Util:GetPlayer(), ingredient.type
    ))
    self.ingredientUI:SetScale(0.64)

    self:SetHoverText(prefabName)

    if options.disabled then
        self.rootButton:Disable()
    end

    self.rootButton:SetOnClick(function ()
        options.chooseItem(ingredient.type)
    end)
end)

return Ingredient
