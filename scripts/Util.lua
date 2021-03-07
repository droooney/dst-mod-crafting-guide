local inspect = require("inspect")

local Constants = require("./Constants")

require("constants")
require("strings")
require("stringutil")

local DEBUG_MODE = true

-- DEBUG_MODE = false

return {
    IsDST = TheSim:GetGameID() == "DST",

    GetWorld = function (self)
        return self.IsDST and TheWorld or GetWorld()
    end,

    GetPlayer = function (self)
        return self.IsDST and ThePlayer or GetPlayer()
    end,

    Inspect = function (self, value)
        return inspect(value)
    end,

    Log = function (self, ...)
        if DEBUG_MODE then
            print("[Crafting Guide]:", ...)
        end
    end,

    GetInventoryItemAtlas = function (self, itemTex)
        return self.IsDST
            and GetInventoryItemAtlas(itemTex)
            or resolvefilepath("images/inventoryimages.xml")
    end,

    GetAllRecipes = function (self, prefab)
        local recipes = {}

        for _, recipe in pairs(AllRecipes) do
            if recipe.tab then
                local ingredientsMatch = function (ingredients)
                    local matches = false

                    for _, ingredient in ipairs(recipe.ingredients) do
                        if ingredient.type == prefab then
                            matches = true

                            break
                        end
                    end

                    return matches
                end

                local matches = (
                    ingredientsMatch(recipe.ingredients)
                    or ingredientsMatch(recipe.tech_ingredients)
                    or ingredientsMatch(recipe.character_ingredients)
                )

                if matches then
                    table.insert(recipes, recipe)
                end
            end
        end

        return recipes
    end,

    GetAllRecipesGrouped = function (self, prefab, groupingType)
        local recipes = self:GetAllRecipes(prefab)
        local groupsMap = {}
        local groups = {}

        for _, recipe in ipairs(recipes) do
            local groupKey

            if groupingType == Constants.ItemsGroupingType.TAB then
                groupKey = recipe.tab.str
            end

            groupsMap[groupKey] = groupsMap[groupKey] or {
                recipes = {},
                title = STRINGS.TABS[recipe.tab.str],
                image = nil,
            }

            table.insert(groupsMap[groupKey].recipes, recipe)
        end

        if groupingType == Constants.ItemsGroupingType.TAB then
            for _, tab in pairs(RECIPETABS) do
                local group = groupsMap[tab.str]

                if group then
                    table.insert(groups, group)
                end
            end
        end

        return groups
    end,

    IsLostRecipe = function (self, recipe)
        return recipe.level.MAGIC >= 10 and recipe.level.SCIENCE >= 10 and recipe.level.ANCIENT >= 10
    end,

    GetPrefabString = function (self, prefab)
        return STRINGS.NAMES[string.upper(prefab)] or prefab
    end,

    GetReplacedString = function (self, template, replacements)
        return subfmt(template, replacements)
    end
}
