local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")
local Spinner = require("widgets/spinner")

local Ingredient = require("CraftingGuide/widgets/Ingredient")

local Constants = require("CraftingGuide/Constants")
local Util = require("CraftingGuide/Util")

require("constants")
require("fonts")
require("mathutil")
require("strings")
require("widgets/widgetutil")

local INGREDIENT_SIZE = 45

local REQUIREMENT_SIZE = 20
local REQUIREMENT_SPACING = 2

--- Recipe
--- @param options.owner      {Player}                                    player instance
--- @param options.skins      {Dictionary<Prefab>}                        chosen skins dictionary
--- @param options.pagePrefab {Prefab}                                    page prefab
--- @param options.closePopup {() => void}                                close item popup
--- @param options.chooseItem {(prefab: Prefab) => void}                  choose item callback
--- @param options.chooseSkin {(itemPrefab: Prefab, skinPrefab) => void}  choose skin callback
local Recipe = Class(Widget, function (self, options)
    Widget._ctor(self, "Recipe")

    self.owner = options.owner
    self.skins = options.skins
    self.pagePrefab = options.pagePrefab
    self.closePopup = options.closePopup
    self.chooseItem = options.chooseItem
    self.chooseSkin = options.chooseSkin

    self.root = self:AddChild(Widget("root"))

    self.rootButton = self.root:AddChild(ImageButton("images/plantregistry.xml", "plant_entry.tex", "plant_entry_focus.tex"))

    self.recipeItemBg = self.rootButton:AddChild(Image("images/plantregistry.xml", "plant_entry_active.tex"))

    self.name = self.rootButton:AddChild(Text(UIFONT, 22))
    self.name:SetPosition(0, 85)
    self.name:SetHAlign(ANCHOR_MIDDLE)

    self.recipeSkins = self.rootButton:AddChild(
        Spinner({}, Constants.RECIPE_WIDTH, nil, nil, nil, nil, {
            arrow_left_normal = "crafting_inventory_arrow_l_idle.tex",
            arrow_left_over = "crafting_inventory_arrow_l_hl.tex",
            arrow_left_disabled = "arrow_left_disabled.tex",
            arrow_left_down = "crafting_inventory_arrow_l_hl.tex",
            arrow_right_normal = "crafting_inventory_arrow_r_idle.tex",
            arrow_right_over = "crafting_inventory_arrow_r_hl.tex",
            arrow_right_disabled = "arrow_right_disabled.tex",
            arrow_right_down = "crafting_inventory_arrow_r_hl.tex",
            bg_middle = "blank.tex",
            bg_middle_focus = "blank.tex",
            bg_middle_changing = "blank.tex",
            bg_end = "blank.tex",
            bg_end_focus = "blank.tex",
            bg_end_changing = "blank.tex",
        }, true)
    )
    self.recipeSkins:SetScale(0.85)
    self.recipeSkins:SetPosition(0, 40)
    self.recipeSkins:SetOnChangedFn(function ()
        if not self.recipe then
            return
        end

        local selectedSkin = self.recipeSkins:GetSelected().data

        self.chooseSkin(self.recipe.name, selectedSkin)
    end)

    self.craftedCount = self.rootButton:AddChild(Text(UIFONT, 28))
    self.craftedCount:SetPosition(30, 20)

    self.ingredients = self.rootButton:AddChild(Widget("ingredients"))
    self.ingredients:SetPosition(0, -20)
    self.ingredients.items = {}

    self.requirements = self.rootButton:AddChild(Widget("requirements"))
    self.requirements:SetPosition(0, -60)
    self.requirements.items = {}

    self.craftButton = self.rootButton:AddChild(ImageButton())
    self.craftButton:SetScale(0.56)
    self.craftButton:SetPosition(0, -90)

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

        local spinnerActive = self.recipeSkins.leftimage.enabled or self.recipeSkins.rightimage.enabled

        if self.recipeSkins.leftimage.focus and spinnerActive then
            self.recipeSkins.leftimage:OnControl(control, down)

            return true
        end

        if self.recipeSkins.rightimage.focus and spinnerActive then
            self.recipeSkins.rightimage:OnControl(control, down)

            return true
        end

        return _OnControl(_, control, down)
    end

    self.root:Hide()
end)

function Recipe:SetRecipeData(recipe)
    self.recipe = recipe

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
    local isSculpture = Util:StartsWith(recipe.name, "chesspiece_")

    self.root:Show()
    self.name:SetTruncatedString(Util:GetPrefabString(recipe.product), 180, nil, true)
    self.craftedCount:SetString(recipe.numtogive == 1 and "" or "x" .. recipe.numtogive)

    local recipeSkins = Util:GetRecipeOwnedSkins(recipe)
    local lastSkin = Profile:GetLastUsedSkinForItem(recipe.name)

    self.recipeSkins:SetOptions(recipeSkins)
    self.recipeSkins:SetSelected(self.skins[recipe.name] or lastSkin)

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
            disabled = true,
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
            disabled = true,
            chooseItem = self.chooseItem,
        }))
    end

    if
        recipe.builder_tag
        and Constants.BUILDER_TAG_MAP[recipe.builder_tag] ~= nil
        and Util:GetSetting(Constants.MOD_OPTIONS.CHAR_SPECIFIC) == Constants.CHAR_SPECIFIC_OPTIONS.SHOW_ALL
    then
        local charName = Constants.BUILDER_TAG_MAP[recipe.builder_tag]
        local avatarIcon = Image("images/avatars.xml", "avatar_" .. charName .. ".tex")

        avatarIcon:SetHoverText(Util:GetReplacedString(
            STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_CHARACTER,
            { character = Util:GetPrefabString(charName) }
        ))
        avatarIcon:SetScale(1.2)

        table.insert(self.requirements.items, avatarIcon)
    end

    if
        not knows
        and Util:IsLostRecipe(recipe)
        and (
            isSculpture
            or Util:GetSetting(Constants.MOD_OPTIONS.GROUP_BY) ~= Constants.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE
        )
    then
        local blueprintOrSketchText = isSculpture
            and "sketch.tex"
            or "blueprint_rare.tex"
        local blueprintOrSketchIcon = Image(
            Util:GetInventoryItemAtlas(blueprintOrSketchText),
            blueprintOrSketchText
        )

        blueprintOrSketchIcon:SetHoverText(
            isSculpture
                and STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_SKETCH
                or STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_RARE_BLUEPRINT
        )

        table.insert(self.requirements.items, blueprintOrSketchIcon)
    end

    if
        isSculpture
        or (not knows and not CanPrototypeRecipe(recipe.level, techLevel))
    then
        local techPrefab

        if isSculpture then
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

            if Util:Includes(Constants.CUSTOM_PREFAB_ICONS, techPrefab) then
                techIcon = Image(Constants.CUSTOM_ICONS_ATLAS, techPrefab .. ".tex")
            else
                local imgTex = techPrefab .. ".tex"

                techIcon = Image(Util:GetInventoryItemAtlas(imgTex), imgTex)
            end

            local techString = Util:GetPrefabString(techPrefab)

            if techPrefab == "moon_altar" then
                techString = (
                    STRINGS.NAMES.MOON_ALTAR
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
        ingredient:SetPosition((i - (#self.ingredients.items + 1) / 2) * INGREDIENT_SIZE, 0)
    end

    for i, requirement in ipairs(self.requirements.items) do
        self.requirements:AddChild(requirement)
        requirement:SetSize(REQUIREMENT_SIZE, REQUIREMENT_SIZE)
        requirement:SetPosition((i - (#self.requirements.items + 1) / 2) * (REQUIREMENT_SIZE + REQUIREMENT_SPACING), 0)
    end

    self.craftButton:SetText(
        (not knows and not recipe.nounlock and canLearn and STRINGS.UI.CRAFTING.PROTOTYPE)
        or (buffered and STRINGS.UI.CRAFTING.PLACE)
        or (
            recipe.actionstr ~= nil
                and STRINGS.UI.CRAFTING.RECIPEACTION[recipe.actionstr]
                or STRINGS.UI.CRAFTING.BUILD
        )
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

        local selectedSkin = self.recipeSkins:GetSelected().data

        DoRecipeClick(self.owner, recipe, selectedSkin)
        Profile:SetLastUsedSkinForItem(recipe.name, selectedSkin)
    end)

    self.rootButton:SetOnClick(function ()
        self.chooseItem(recipe.product)
    end)
end

return Recipe
