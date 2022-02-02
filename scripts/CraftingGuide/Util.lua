local inspect = require("inspect")

local Constants = require("CraftingGuide/Constants")

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

    FindIndex = function (self, array, cb)
        for i, v in ipairs(array) do
            if cb(v, i, array) then
                return i
            end
        end

        return 0
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

        table.sort(recipes, function (recipe1, recipe2)
            return recipe1.sortkey < recipe2.sortkey
        end)

        return recipes
    end,

    GetAllRecipesGrouped = function (self, prefab, groupingType)
        local recipes = self:GetAllRecipes(prefab)
        local groupsMap = {}
        local groups = {}
        local isTabGrouping = groupingType == Constants.ItemsGroupingType.TAB

        for _, recipe in ipairs(recipes) do
            local groupKey

            if isTabGrouping then
                groupKey = recipe.tab.str
            end

            groupsMap[groupKey] = groupsMap[groupKey] or {
                recipes = {},
                tab = recipe.tab,
            }

            table.insert(groupsMap[groupKey].recipes, recipe)
        end

        for _, group in pairs(groupsMap) do
            table.insert(groups, group)
        end

        table.sort(groups, function (group1, group2)
            if isTabGrouping then
                return group1.tab.sort < group2.tab.sort
            end

            return true
        end)

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
    end,
}
