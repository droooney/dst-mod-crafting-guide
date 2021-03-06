local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")

local Ingredient = require("./widgets/Ingredient")

local Constants = require("./Constants")
local Util = require("./Util")

require("constants")
require("fonts")
require("mathutil")
require("strings")
require("widgets/widgetutil")

local INGREDIENT_SIZE = 45

local REQUIREMENT_SIZE = 20
local REQUIREMENT_SPACING = 2

--- Recipe
-- @param options.owner      {Player}                    player instance
-- @param options.pagePrefab {Prefab}                    page prefab
-- @param options.closePopup {() => void}                close item popup
-- @param options.chooseItem {(prefab: Prefab) => void}  choose item callback
local Recipe = Class(Widget, function (self, options)
    Widget._ctor(self, "Recipe")

    self.owner = options.owner
    self.pagePrefab = options.pagePrefab
    self.closePopup = options.closePopup
    self.chooseItem = options.chooseItem
    self.root = self:AddChild(Widget("root"))
    self.rootButton = self.root:AddChild(ImageButton("images/plantregistry.xml", "plant_entry.tex", "plant_entry_focus.tex"))
    self.recipeItemBg = self.rootButton:AddChild(Image("images/plantregistry.xml", "plant_entry_active.tex"))
    self.name = self.rootButton:AddChild(Text(UIFONT, 22))
    self.recipeImage = self.rootButton:AddChild(Image())
    self.craftedCount = self.rootButton:AddChild(Text(UIFONT, 28))
    self.ingredients = self.rootButton:AddChild(Widget("ingredients"))
    self.requirements = self.rootButton:AddChild(Widget("requirements"))
    self.craftButton = self.rootButton:AddChild(ImageButton())

    self.ingredients.items = {}
    self.requirements.items = {}

    self.name:SetPosition(0, 85, 0)
    self.name:SetHAlign(ANCHOR_MIDDLE)

    self.recipeImage:SetScale(0.8)
    self.recipeImage:SetPosition(0, 40, 0)
    self.craftedCount:SetPosition(30, 20, 0)
    self.ingredients:SetPosition(0, -20, 0)
    self.requirements:SetPosition(0, -60, 0)

    self.craftButton:SetScale(0.56)
    self.craftButton:SetPosition(0, -90, 0)

    local _OnControl = self.rootButton.OnControl

    self.rootButton.OnControl = function (_, control, down)
        if control ~= CONTROL_ACCEPT then
            return _OnControl(_, control, down)
        end

        if self.craftButton.focus then
            self.craftButton:OnControl(control, down)

            return true
        end

        for _, ingredient in ipairs(self.ingredients.items) do
            if ingredient.rootButton.focus then
                ingredient.rootButton:OnControl(control, down)

                return true
            end
        end

        return _OnControl(_, control, down)
    end

    self.root:Hide()
end)

function Recipe:SetRecipeData(recipe)
    if not recipe then
        self.root:Hide()

        return
    end

    local builder = self.owner.replica.builder
    local inventory = self.owner.replica.inventory
    local knows = builder:KnowsRecipe(recipe.name)
    local buffered = builder:IsBuildBuffered(recipe.name)
    local canBuild = builder:CanBuild(recipe.name)
    local canLearn = builder:CanLearn(recipe.name)
    local techLevel = builder:GetTechTrees()
    local techBonuses = builder:GetTechBonuses()
    local shouldHint = not knows and not (canLearn and CanPrototypeRecipe(recipe.level, techLevel))

    self.root:Show()
    self.name:SetTruncatedString(Util:GetPrefabString(recipe.product), 180, nil, true)
    self.recipeImage:SetTexture(recipe:GetAtlas(), recipe.image)
    self.craftedCount:SetString(recipe.numtogive == 1 and "" or "x" .. recipe.numtogive)

    for _, ingredient in ipairs(self.ingredients.items) do
        ingredient:Kill()
    end

    for _, requirement in ipairs(self.requirements.items) do
        requirement:Kill()
    end

    self.ingredients.items = {}
    self.requirements.items = {}

    for _, ingredient in ipairs(recipe.tech_ingredients) do
        local has = builder:HasTechIngredient(ingredient)

        table.insert(self.ingredients.items, Ingredient({
            ingredient = ingredient,
            needed = nil,
            onHand = nil,
            has = has,
            disabled = ingredient.type == self.pagePrefab,
            chooseItem = self.chooseItem,
        }))
    end

    for _, ingredient in ipairs(recipe.ingredients) do
        local has, onHand = inventory:Has(ingredient.type, RoundBiasedUp(ingredient.amount * builder:IngredientMod()))

        table.insert(self.ingredients.items, Ingredient({
            ingredient = ingredient,
            needed = ingredient.amount,
            onHand = onHand,
            has = has,
            disabled = ingredient.type == self.pagePrefab,
            chooseItem = self.chooseItem,
        }))
    end

    for _, ingredient in ipairs(recipe.character_ingredients) do
        local has, amount = builder:HasCharacterIngredient(ingredient)

        table.insert(self.ingredients.items, Ingredient({
            ingredient = ingredient,
            needed = ingredient.amount,
            onHand = amount,
            has = has,
            disabled = ingredient.type == self.pagePrefab,
            chooseItem = self.chooseItem,
        }))
    end

    local tabIcon = Image(recipe.tab.icon_atlas or "images/hud.xml", recipe.tab.icon)

    tabIcon:SetHoverText(Util:GetReplacedString(
        STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_TAB,
        { tab = STRINGS.TABS[recipe.tab.str] }
    ))
    tabIcon:SetScale(1.1)

    table.insert(self.requirements.items, tabIcon)

    if recipe.builder_tag and Constants.BUILDER_TAG_MAP[recipe.builder_tag] ~= nil then
        local charName = Constants.BUILDER_TAG_MAP[recipe.builder_tag]
        local avatarIcon = Image("images/avatars.xml", "avatar_" .. charName .. ".tex")

        avatarIcon:SetHoverText(Util:GetReplacedString(
            STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_CHARACTER,
            { character = Util:GetPrefabString(charName) }
        ))
        avatarIcon:SetScale(1.2)

        table.insert(self.requirements.items, avatarIcon)
    end

    if not knows and Util:IsLostRecipe(recipe) then
        local blueprintOrSketchIcon = Image(
            "images/inventoryimages.xml",
            recipe.tab == RECIPETABS.SCULPTING
                and "sketch.tex"
                or "blueprint_rare.tex"
        )

        blueprintOrSketchIcon:SetHoverText(
            recipe.tab == RECIPETABS.SCULPTING
                and STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_SKETCH
                or STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_RARE_BLUEPRINT
        )

        table.insert(self.requirements.items, blueprintOrSketchIcon)
    end

    if
        recipe.tab == RECIPETABS.SCULPTING
        or (not knows and not CanPrototypeRecipe(recipe.level, techLevel))
    then
        local techPrefab

        if recipe.tab == RECIPETABS.SCULPTING then
            techPrefab = Constants.REQUIRED_TECH.SCULPTING_1
        else
            for tech, value in pairs(recipe.level) do
                value = value - (techBonuses[tech] or 0)

                techPrefab = Constants.REQUIRED_TECH[tech .. "_" .. value]

                if techPrefab then
                    break
                end
            end
        end

        if techPrefab then
            local techIcon

            if Constants.CUSTOM_PREFAB_ICONS[techPrefab] then
                techIcon = Image(Constants.CUSTOM_ICONS_ATLAS, techPrefab .. ".tex")
            else
                local imgTex = techPrefab .. ".tex"

                techIcon = Image(Util:GetInventoryItemAtlas(imgTex), imgTex)
            end

            local techString = Util:GetPrefabString(techPrefab)

            if techPrefab == "moon_altar" then
                techString = (
                    STRINGS.NAMES.MOON_ALTAR.MOON_ALTAR
                    .. "/" .. STRINGS.NAMES.MOON_ALTAR_COSMIC
                    .. "/" .. STRINGS.NAMES.MOON_ALTAR_ASTRAL
                )
            end

            techIcon:SetHoverText(Util:GetReplacedString(
                recipe.nounlock
                    and STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_TECH_NEAR_BUILD
                    or STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_TECH_NEAR_PROTOTYPE,
                { tech = techString }
            ))

            table.insert(self.requirements.items, techIcon)
        end
    end

    for i, ingredient in ipairs(self.ingredients.items) do
        self.ingredients:AddChild(ingredient)
        ingredient:SetPosition((i - (#self.ingredients.items + 1) / 2) * INGREDIENT_SIZE, 0, 0)
    end

    for i, requirement in ipairs(self.requirements.items) do
        self.requirements:AddChild(requirement)
        requirement:SetSize(REQUIREMENT_SIZE, REQUIREMENT_SIZE)
        requirement:SetPosition((i - (#self.requirements.items + 1) / 2) * (REQUIREMENT_SIZE + REQUIREMENT_SPACING), 0, 0)
    end

    self.craftButton:SetText(
        (not knows and not recipe.nounlock and canLearn and STRINGS.UI.CRAFTING.PROTOTYPE)
        or (buffered and STRINGS.UI.CRAFTING.PLACE)
        or STRINGS.UI.CRAFTING.TABACTION[recipe.tab.str]
        or STRINGS.UI.CRAFTING.BUILD
    )

    if (buffered or canBuild) and not shouldHint then
        self.craftButton:Enable()
    else
        self.craftButton:Disable()
    end

    self.craftButton:SetOnClick(function ()
        if recipe.placer then
            self.closePopup()
        end

        -- TODO: add support for skins
        DoRecipeClick(self.owner, recipe, recipe.name)
    end)

    self.rootButton:SetOnClick(function ()
        self.chooseItem(recipe.name)
    end)
end

return Recipe
