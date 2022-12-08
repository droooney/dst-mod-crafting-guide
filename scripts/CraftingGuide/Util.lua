local inspect = require("inspect")

local Constants = require("CraftingGuide/Constants")

require("constants")
require("strings")
require("stringutil")

local KNOWLEDGE_SORT = {
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.KNOWN_RECIPE,
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.UNKNOWN_RECIPE,
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.RARE_BLUEPRINT,
    Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.NO_BLUEPRINT,
}

return {
    isDST = TheSim:GetGameID() == "DST",
    modname = nil,
    global = nil,
    settings = nil,
    bindings = {},

    SetModName = function (self, modname)
        self.modname = modname
    end,

    SetGlobal = function (self, global)
        self.global = global
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

    GetBooleanSetting = function (self, name, default)
        local value = self:GetSetting(name)

        if value == Constants.BOOLEAN_OPTIONS.YES then
            return true
        end

        if value == Constants.BOOLEAN_OPTIONS.NO then
            return false
        end

        if default ~= true and default ~= false then
            return false
        end

        return default
    end,

    GetSetting = function (self, name)
        return self.settings[name]
    end,

    SetSetting = function (self, name, value)
        local oldValue = self.settings[name]

        if oldValue == value then
            return
        end

        self.settings[name] = value

        if name == Constants.MOD_OPTIONS.KEY_OPEN_ALL then
            self:ChangeKeyBinding(value, name)
        end
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
        print("[Crafting Guide]:", ...)
    end,

    FindIndex = function (self, array, cb)
        for i, v in ipairs(array) do
            if cb(v, i, array) then
                return i
            end
        end

        return 0
    end,

    Find = function (self, array, cb)
        for i, v in ipairs(array) do
            if cb(v, i, array) then
                return v
            end
        end
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

    StartsWith = function (self, str, start)
        return str:sub(1, #start) == start
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
        local recipeFilters = {}
        local filtersSorting = {}

        for index, filterDef in ipairs(CRAFTING_FILTER_DEFS) do
            filtersSorting[filterDef.name] = index
        end

        for filterName, filter in pairs(CRAFTING_FILTERS) do
            local filterRecipes = FunctionOrValue(filter.recipes) or {}

            for _, recipeName in ipairs(filterRecipes) do
                if filtersSorting[filterName] then
                    recipeFilters[recipeName] = recipeFilters[recipeName] or {}

                    table.insert(recipeFilters[recipeName], filterName)
                end
            end
        end

        for _, recipe in pairs(AllRecipes) do
            if recipeFilters[recipe.name] then
                local matches = prefab == nil

                if not matches then
                    for _, ingredient in ipairs(recipe.ingredients) do
                        if ingredient.type == prefab then
                            matches = true

                            break
                        end
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

        return recipes, recipeFilters, filtersSorting
    end,

    GetAllRecipesGrouped = function (self, prefab)
        local player = self:GetPlayer()
        local builder = player.replica.builder
        local recipes, recipeFilters, filtersSorting = self:GetAllRecipes(prefab)
        local groupsMap = {}
        local groups = {}
        local groupBy = self:GetSetting(Constants.MOD_OPTIONS.GROUP_BY)
        local isTabGrouping = groupBy == Constants.GROUP_BY_OPTIONS.CRAFTING_TAB
        local isKnowledgeGrouping = groupBy == Constants.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE

        for _, recipe in ipairs(recipes) do
            local groupKeys = {"all"}

            if isTabGrouping then
                groupKeys = recipeFilters[recipe.name] or {}
            elseif isKnowledgeGrouping then
                if recipe.nounlock then
                    groupKeys = {Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.NO_BLUEPRINT}
                else
                    local hasTag = recipe.builder_tag == nil or builder.inst:HasTag(recipe.builder_tag)

                    if not hasTag then
                        -- temporarily add builder tag to find out if prototyping is required
                        builder.inst:AddTag(recipe.builder_tag)
                    end

                    local knows = builder:KnowsRecipe(recipe.name)
                    local canLearn = builder:CanLearn(recipe.name)

                    if not hasTag then
                        builder.inst:RemoveTag(recipe.builder_tag)
                    end

                    groupKeys = not knows and canLearn
                        and (
                            self:IsLostRecipe(recipe)
                                and {Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.RARE_BLUEPRINT}
                                or {Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.UNKNOWN_RECIPE}
                        )
                        or {Constants.GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS.KNOWN_RECIPE}
                end
            end

            for _, groupKey in ipairs(groupKeys) do
                groupsMap[groupKey] = groupsMap[groupKey] or {
                    key = groupKey,
                    recipes = {},
                }

                table.insert(groupsMap[groupKey].recipes, recipe)
            end
        end

        for _, group in pairs(groupsMap) do
            table.insert(groups, group)
        end

        table.sort(groups, function (group1, group2)
            if isTabGrouping then
                return filtersSorting[group1.key] < filtersSorting[group2.key]
            end

            if isKnowledgeGrouping then
                return self:IndexOf(KNOWLEDGE_SORT, group1.key) < self:IndexOf(KNOWLEDGE_SORT, group2.key)
            end

            return true
        end)

        return groups
    end,

    GetRecipeIngredientsCount = function (self, recipe)
        local count = 0

        for _ in ipairs(recipe.tech_ingredients) do
            count = count + 1
        end

        for _ in ipairs(recipe.ingredients) do
            count = count + 1
        end

        for _ in ipairs(recipe.character_ingredients) do
            count = count + 1
        end

        return count
    end,

    GetRecipeOwnedSkins = function (self, recipe)
        local list = {
            {
                skin = recipe.product,
                atlas = recipe:GetAtlas(),
                tex = recipe.image,
            }
        }
        local skins = PREFAB_SKINS[recipe.product]

        if skins then
            for _, skin in ipairs(PREFAB_SKINS[recipe.product]) do
                if TheInventory:CheckOwnershipGetLatest(skin) then
                    local tex = skin .. ".tex"

                    table.insert(list, {
                        skin = skin,
                        atlas = self:GetInventoryItemAtlas(tex),
                        tex = tex,
                    })
                end
            end
        end

        return self:Map(list, function (item)
            return {
                data = item.skin,
                image = {item.atlas, item.tex, "default.tex"},
            }
        end)
    end,

    IsLostRecipe = function (self, recipe)
        return recipe.level.MAGIC >= 10 and recipe.level.SCIENCE >= 10 and recipe.level.ANCIENT >= 10
    end,

    GetItemPrefab = function (self, item)
        local prefab = item.prefab

        if prefab == "tophat" and item:HasTag("magiciantool") then
            prefab = "tophat_magician"
        end

        return prefab
    end,

    GetPrefabString = function (self, prefab)
        return STRINGS.NAMES[string.upper(prefab)] or prefab
    end,

    GetReplacedString = function (self, template, replacements)
        return subfmt(template, replacements)
    end,

    SetKeyBinding = function (self, settingName, callback)
        self.bindings[settingName] = {
            callback = callback,
        }

        local binding = self:GetSetting(settingName)

        if binding ~= "NONE" then
            self.bindings[settingName].handler = TheInput:AddKeyUpHandler(self.global[binding], callback)
        end
    end,

    ChangeKeyBinding = function (self, newBinding, settingName)
        local binding = self.bindings[settingName]
        local handler = binding.handler

        if handler then
            TheInput.onkeyup:RemoveHandler(handler)
        end

        if newBinding ~= "NONE" then
            self.bindings[settingName].handler = TheInput:AddKeyUpHandler(self.global[newBinding], binding.callback)
        end
    end,

    IsWidgetOpen = function ()
        local activeScreen = TheFrontEnd:GetActiveScreen()

        if activeScreen and activeScreen.name == "CraftingGuideScreen" then
            return true
        end

        return false
    end,
}
