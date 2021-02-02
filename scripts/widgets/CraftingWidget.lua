local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")
local RecipePopup = require("widgets/recipepopup")
local Image = require("widgets/image")
local Text = require("widgets/text")
local IngredientUI = require("widgets/ingredientui")
local Grid = require("widgets/grid")
local ScrollableList = require("widgets/scrollablelist")
local ImageButton = require("widgets/imagebutton")

require("constants")
require("fonts")
require("mathutil")
require("strings")
require("widgets/widgetutil")

local IngredientWidget = require("./widgets/IngredientWidget")
local Util = require("./Util")

local RECIPE_WIDTH = 200
local RECIPE_HEIGHT = 290
local RECIPE_SPACING = 5

local INGREDIENT_SIZE = 55
local INGREDIENT_SPACING = 3

local REQUIREMENT_SIZE = 25
local REQUIREMENT_SPACING = 2

local BUILDER_TAG_MAP = {
    pyromaniac = "willow",
    spiderwhisperer = "webber",
    ghostlyfriend = "wendy",
    masterchef = "warly",
    pinetreepioneer = "walter",
    werehuman = "woodie",
    valkyrie = "wathgrithr",
    pebblemaker = "walter",
    merm_builder = "wurt",
    bookbuilder = "wickerbottom",
    shadowmagic = "waxwell",
    handyperson = "winona",
    elixirbrewer = "wendy",
    battlesinger = "wathgrithr",
    professionalchef = "warly",
    plantkin = "wormwood",
}

local IMPORTANT_EVENTS = {
    "techtreechange", "itemget", "itemlose", "newactiveitem",
    "stacksizechange", "unlockrecipe", "refreshcrafting", "refreshinventory"
}

local REQUIRED_TECH = {
    SCIENCE_1 = "researchlab",
    SCIENCE_2 = "researchlab2",
    SCIENCE_3 = "researchlab2",

    MAGIC_2 = "researchlab4",
    MAGIC_3 = "researchlab3",

    ANCIENT_2 = "ancient_altar_broken",
    ANCIENT_4 = "ancient_altar",

    CELESTIAL_1 = "moonrockseed",

    MOON_ALTAR_2 = "moon_altar",

    SHADOW_3 = "waxwelljournal",

    SEAFARING_2 = "seafaring_prototyper",

    SCULPTING_1 = "sculptingtable",

    -- FIXME: fix image
    ORPHANAGE_1 = "critterlab",

    MADSCIENCE_1 = "madscience_lab",

    FOODPROCESSING_1 = "madscience_lab",

    -- TODO: finish all
}

local CraftingWidget = Class(Widget, function (self, prefab, close)
    Widget._ctor(self, "CraftingWidget")

    self.prefab = prefab
    self.owner = Util:GetPlayer()
    self.close = close
    self.needToUpdateRecipes = false
    self.allRecipes = Util:GetAllRecipes(prefab)
    self.root = self:AddChild(Widget("root"))

    Util:Log("recipes count", #self.allRecipes)

    local dialog = self.root:AddChild(Templates.RectangleWindow(890, 500))

    self.grid = dialog:AddChild(Templates.ScrollingGrid(self.allRecipes, {
        scroll_context = {
            screen = self,
        },
        widget_width = RECIPE_WIDTH + RECIPE_SPACING,
        widget_height = RECIPE_HEIGHT + RECIPE_SPACING,
        num_visible_rows = 1.3,
        num_columns = 4,
        item_ctor_fn = function (...) return self:InitGridItem(...) end,
        apply_fn = function (...) return self:FillGridItem(...) end,
        scrollbar_offset = 20,
        scrollbar_height_offset = -60
    }))

    self.root:AddChild(Templates.BackButton(close))

    local lastHealthSeg = nil
    local lastHealthPenaltySeg = nil
    local lastSanitySeg = nil
    local lastSanityPenaltySeg = nil

    local function OnHealthDeltaChange(owner, data)
        local health = owner.replica.health

        if health then
            local currentSeg = math.floor(math.ceil(data.newpercent * health:Max()) / CHARACTER_INGREDIENT_SEG)
            local penaltySeg = health:GetPenaltyPercent()

            if currentSeg ~= lastHealthSeg or penaltySeg ~= lastHealthPenaltySeg then
                lastHealthSeg = currentSeg
                lastHealthPenaltySeg = penaltySeg
                self.needToUpdateRecipes = true
            end
        end
    end

    local function OnSanityDeltaChange(owner, data)
        local sanity = owner.replica.sanity

        if sanity then
            local currentSeg = math.floor(math.ceil(data.newpercent * sanity:Max()) / CHARACTER_INGREDIENT_SEG)
            local penaltySeg = sanity:GetPenaltyPercent()

            if currentSeg ~= lastSanitySeg or penaltySeg ~= lastSanityPenaltySeg then
                lastSanitySeg = currentSeg
                lastSanityPenaltySeg = penaltySeg
                self.needToUpdateRecipes = true
            end
        end
    end

    self.inst:ListenForEvent("healthdelta", OnHealthDeltaChange, self.owner)
    self.inst:ListenForEvent("sanitydelta", OnSanityDeltaChange, self.owner)

    for _, event in ipairs(IMPORTANT_EVENTS) do
        self.inst:ListenForEvent(event, function () self.needToUpdateRecipes = true end, self.owner)
    end
end)

function CraftingWidget:InitGridItem(context, i)
    local gridItem = Widget("craftingWidgetGridItem")

    gridItem.root = gridItem:AddChild(Widget("root"))
    gridItem.recipeItemBg = gridItem.root:AddChild(Image("images/plantregistry.xml", "plant_entry_active.tex"))
    gridItem.name = gridItem.root:AddChild(Text(UIFONT, 28))
    gridItem.recipeImage = gridItem.root:AddChild(Image())
    gridItem.craftedCount = gridItem.root:AddChild(Text(UIFONT, 32))
    gridItem.ingredients = gridItem.root:AddChild(Widget("ingredients"))
    gridItem.requirements = gridItem.root:AddChild(Widget("requirements"))
    gridItem.craftButton = gridItem.root:AddChild(ImageButton())

    gridItem.ingredients.items = {}
    gridItem.requirements.items = {}

    gridItem.recipeItemBg:SetScale(1.25, 1.25, 1.25)

    gridItem.name:SetPosition(0, 100, 0)
    gridItem.name:SetHAlign(ANCHOR_MIDDLE)

    gridItem.recipeImage:SetPosition(0, 47, 0)
    gridItem.craftedCount:SetPosition(30, 25, 0)
    gridItem.ingredients:SetPosition(0, -20, 0)
    gridItem.requirements:SetPosition(0, -70, 0)

    gridItem.craftButton:SetScale(0.7, 0.7, 0.7)
    gridItem.craftButton:SetPosition(0, -110, 0)

    gridItem.root:Hide()

    return gridItem
end

function CraftingWidget:FillGridItem(context, gridItem, recipe, i)
    if not recipe then
        gridItem.root:Hide()

        return
    end

    local builder = self.owner.replica.builder
    local inventory = self.owner.replica.inventory
    local knows = builder:KnowsRecipe(recipe.name)
    local buffered = builder:IsBuildBuffered(recipe.name)
    local canBuild = builder:CanBuild(recipe.name)
    local techLevel = builder:GetTechTrees()
    local shouldHint = not knows and not (builder:CanLearn(recipe.name) and CanPrototypeRecipe(recipe.level, techLevel))

    gridItem.root:Show()
    gridItem.name:SetTruncatedString(Util:GetPrefabString(recipe.product), 180, nil, true)
    gridItem.recipeImage:SetTexture(recipe:GetAtlas(), recipe.image)
    gridItem.craftedCount:SetString(recipe.numtogive == 1 and "" or "x" .. recipe.numtogive)

    for _, ingredient in ipairs(gridItem.ingredients.items) do
        ingredient:Kill()
    end

    for _, requirement in ipairs(gridItem.requirements.items) do
        requirement:Kill()
    end

    gridItem.ingredients.items = {}
    gridItem.requirements.items = {}

    for _, ingredient in ipairs(recipe.tech_ingredients) do
        local has = builder:HasTechIngredient(ingredient)

        table.insert(gridItem.ingredients.items, IngredientWidget(ingredient, nil, nil, has))
    end

    for _, ingredient in ipairs(recipe.ingredients) do
        local has, onHand = inventory:Has(ingredient.type, RoundBiasedUp(ingredient.amount * builder:IngredientMod()))

        table.insert(gridItem.ingredients.items, IngredientWidget(ingredient, ingredient.amount, onHand, has))
    end

    for _, ingredient in ipairs(recipe.character_ingredients) do
        local has, amount = builder:HasCharacterIngredient(ingredient)

        table.insert(gridItem.ingredients.items, IngredientWidget(ingredient, ingredient.amount, amount, has))
    end

    local tabIcon = Image(recipe.tab.icon_atlas or "images/hud.xml", recipe.tab.icon)

    tabIcon:SetScale(0.25, 0.25, 0.25)
    tabIcon:SetHoverText(Util:GetReplacedString(
        STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_TAB,
        { tab = STRINGS.TABS[recipe.tab.str] }
    ))

    table.insert(gridItem.requirements.items, tabIcon)

    if recipe.builder_tag and BUILDER_TAG_MAP[recipe.builder_tag] ~= nil then
        local charName = BUILDER_TAG_MAP[recipe.builder_tag]
        local avatarIcon = Image("images/avatars.xml", "avatar_" .. charName .. ".tex")

        avatarIcon:SetScale(0.4, 0.4, 0.4)
        avatarIcon:SetHoverText(Util:GetReplacedString(
            STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_CHARACTER,
            { character = Util:GetPrefabString(charName) }
        ))

        table.insert(gridItem.requirements.items, avatarIcon)
    end

    if not knows and Util:IsLostRecipe(recipe) then
        local blueprintOrSketchIcon = Image(
            "images/inventoryimages.xml",
            recipe.tab == RECIPETABS.SCULPTING
                and "sketch.tex"
                or "blueprint_rare.tex"
        )

        blueprintOrSketchIcon:SetScale(0.4, 0.4, 0.4)
        blueprintOrSketchIcon:SetHoverText(
            recipe.tab == RECIPETABS.SCULPTING
                and STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_SKETCH
                or STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_RARE_BLUEPRINT
        )

        table.insert(gridItem.requirements.items, blueprintOrSketchIcon)
    end

    if
        recipe.tab == RECIPETABS.SCULPTING
        or (not knows and not CanPrototypeRecipe(recipe.level, techLevel))
    then
        local techPrefab

        if recipe.tab == RECIPETABS.SCULPTING then
            techPrefab = REQUIRED_TECH.SCULPTING_1
        else
            for tech, value in pairs(recipe.level) do
                -- FIXME: fix for wickerbottom

                techPrefab = REQUIRED_TECH[tech .. "_" .. value]

                if techPrefab then
                    break
                end
            end
        end

        if techPrefab then
            local techIcon

            if techPrefab == "ancient_altar_broken" or techPrefab == "ancient_altar" then
                techIcon = Image(recipe.tab.icon_atlas or "images/hud.xml", recipe.tab.icon)

                techIcon:SetScale(0.25, 0.25, 0.25)
            else
                local imgTex = techPrefab .. ".tex"

                techIcon = Image(Util:GetInventoryItemAtlas(imgTex), imgTex)

                techIcon:SetScale(0.4, 0.4, 0.4)
            end

            local techString = Util:GetPrefabString(techPrefab)

            techIcon:SetHoverText(Util:GetReplacedString(
                recipe.nounlock
                    and STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_TECH_NEAR_BUILD
                    or STRINGS.CRAFTING_GUIDE.REQUIREMENT_ICONS.REQUIRES_TECH_NEAR_PROTOTYPE,
                { tech = techString }
            ))

            table.insert(gridItem.requirements.items, techIcon)
        end
    end

    for i, ingredient in ipairs(gridItem.ingredients.items) do
        gridItem.ingredients:AddChild(ingredient)
        ingredient:SetPosition((i - (#gridItem.ingredients.items + 1) / 2) * (INGREDIENT_SIZE + INGREDIENT_SPACING), 0, 0)
    end

    for i, requirement in ipairs(gridItem.requirements.items) do
        gridItem.requirements:AddChild(requirement)
        requirement:SetPosition((i - (#gridItem.requirements.items + 1) / 2) * (REQUIREMENT_SIZE + REQUIREMENT_SPACING), 0, 0)
    end

    gridItem.craftButton:SetText(
        (not (knows or recipe.nounlock) and STRINGS.UI.CRAFTING.PROTOTYPE)
            or (buffered and STRINGS.UI.CRAFTING.PLACE)
            or STRINGS.UI.CRAFTING.TABACTION[recipe.tab.str]
            or STRINGS.UI.CRAFTING.BUILD
    )

    if (buffered or canBuild) and not shouldHint then
        gridItem.craftButton:Enable()
    else
        gridItem.craftButton:Disable()
    end

    gridItem.craftButton:SetOnClick(function ()
        if recipe.placer then
            self.close()
        end

        -- TODO: add support for skins
        DoRecipeClick(self.owner, recipe, recipe.name)
    end)
end

function CraftingWidget:OnUpdate()
    if self.needToUpdateRecipes then
        Util:Log("updating recipes")

        self.needToUpdateRecipes = false

        self.grid:RefreshView()
    end
end

return CraftingWidget
