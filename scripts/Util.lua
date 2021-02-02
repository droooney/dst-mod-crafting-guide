local inspect = require("inspect")

require("strings")
require("stringutil")

local DEBUG_MODE = true

--DEBUG_MODE = false

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

    GetPrefabInfo = function (self, prefab)
        local itemTex = prefab .. ".tex"
        local atlas = GetInventoryItemAtlas(itemTex)
        local name = STRINGS.NAMES[string.upper(prefab)] or prefab
        local prefabData = Prefabs[prefab]

        if prefabData then
            -- first run we find assets with exact match of prefab name
            if not atlas or not TheSim:AtlasContains(atlas, itemTex) then
                for _, asset in ipairs(prefabData.assets) do
                    if asset.type == "INV_IMAGE" then
                        itemTex = asset.file .. ".tex"
                        atlas = GetInventoryItemAtlas(itemTex)
                    elseif asset.type == "ATLAS" then
                        atlas = asset.file
                    end
                end
            end

            -- second run, a special case for migrated items, they are prefixed via `quagmire_`
            if not atlas or not TheSim:AtlasContains(atlas, itemTex) then
                for _, asset in ipairs(Prefabs[prefab].assets) do
                    if asset.type == "INV_IMAGE" then
                        itemTex = "quagmire_" .. asset.file .. ".tex"
                        atlas = GetInventoryItemAtlas(itemTex)
                    end
                end
            end
        end

        if not atlas or not TheSim:AtlasContains(atlas, itemTex) then
            itemTex = nil
            atlas = nil
        end

        return { itemTex = itemTex, atlas = atlas, name = name }
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
