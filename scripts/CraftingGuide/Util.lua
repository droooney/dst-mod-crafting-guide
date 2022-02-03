local inspect = require("inspect")

local Constants = require("CraftingGuide/Constants")

require("constants")
require("strings")
require("stringutil")

local DEBUG_MODE = true

-- DEBUG_MODE = false

local KNOWLEDGE_SORT = {
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.KNOWN_RECIPE,
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.UNKNOWN_RECIPE,
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.NO_BLUEPRINT,
}

return {
    isDST = TheSim:GetGameID() == "DST",
    modname = nil,
    settings = nil,

    SetModName = function (self, modname)
        self.modname = modname
    end,

    GetSettings = function (self)
        local clonedSettings = {}

        for name, value in pairs(self.settings) do
            clonedSettings[name] = value
        end

        return clonedSettings
    end,

    GetSettingsConfig = function (self)
        return KnownModIndex:LoadModConfigurationOptions(self.modname, true)
    end,

    SetSettings = function (self, settings)
        self.settings = settings
    end,

    GetSetting = function (self, name)
        return self.settings[name]
    end,

    SetSetting = function (self, name, value)
        self.settings[name] = value
    end,

    SaveSettings = function (self)
        local settingsConfig = self:GetSettingsConfig()

        for _, setting in ipairs(settingsConfig) do
            local localSetting = self.settings[setting.name]

            if localSetting then
                setting.saved = localSetting
            end
        end

        KnownModIndex:SaveConfigurationOptions(function() end, self.modname, settingsConfig, true)
    end,

    HaveSettingsChanged = function (self, oldSettings)
        local currentSettings = self.settings

        for name, value in pairs(currentSettings) do
            if oldSettings[name] ~= value then
                return true;
            end
        end

        return false
    end,

    GetWorld = function (self)
        return self.isDST and TheWorld or GetWorld()
    end,

    GetPlayer = function (self)
        return self.isDST and ThePlayer or GetPlayer()
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

    IndexOf = function (self, array, value)
        return self:FindIndex(array, function (arrayValue)
            return arrayValue == value
        end)
    end,

    Includes = function (self, array, value)
        return self:IndexOf(array, value) ~= 0
    end,

    Map = function (self, array, cb)
        local newArray = {}

        for i, v in ipairs(array) do
            table.insert(newArray, cb(v, i, array))
        end

        return newArray
    end,

    GetInventoryItemAtlas = function (self, itemTex)
        return self.isDST
            and GetInventoryItemAtlas(itemTex)
            or resolvefilepath("images/inventoryimages.xml")
    end,

    GetAllRecipes = function (self, prefab)
        local player = self:GetPlayer()
        local builder = player.replica.builder
        local charSpecific = self:GetSetting(Constants.MOD_OPTIONS.CHAR_SPECIFIC)
        local recipes = {}

        for _, recipe in pairs(AllRecipes) do
            if recipe.tab then
                local matches = false

                for _, ingredient in ipairs(recipe.ingredients) do
                    if ingredient.type == prefab then
                        matches = true

                        break
                    end
                end

                if
                    recipe.builder_tag
                    and (
                        charSpecific == Constants.CHAR_SPECIFIC_OPTIONS.HIDE
                        or (charSpecific == Constants.CHAR_SPECIFIC_OPTIONS.SHOW_MINE and not builder.inst:HasTag(recipe.builder_tag))
                    )
                then
                    matches = false
                end

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

    GetAllRecipesGrouped = function (self, prefab)
        local player = self:GetPlayer()
        local builder = player.replica.builder
        local recipes = self:GetAllRecipes(prefab)
        local groupsMap = {}
        local groups = {}
        local groupBy = self:GetSetting(Constants.MOD_OPTIONS.GROUP_BY)
        local isTabGrouping = groupBy == Constants.GROUP_BY_OPTIONS.CRAFTING_TAB
        local isKnowledgeGrouping = groupBy == Constants.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE

        for _, recipe in ipairs(recipes) do
            local groupKey = "all"

            if isTabGrouping then
                groupKey = recipe.tab.str
            elseif isKnowledgeGrouping then
                if recipe.nounlock then
                    groupKey = Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.NO_BLUEPRINT
                else
                    local knows = builder:KnowsRecipe(recipe.name)
                    local canLearn = builder:CanLearn(recipe.name)

                    groupKey = not knows and canLearn
                        and Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.UNKNOWN_RECIPE
                        or Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.KNOWN_RECIPE
                end
            end

            groupsMap[groupKey] = groupsMap[groupKey] or {
                key = groupKey,
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

            if isKnowledgeGrouping then
                return self:IndexOf(KNOWLEDGE_SORT, group1.key) < self:IndexOf(KNOWLEDGE_SORT, group2.key)
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
