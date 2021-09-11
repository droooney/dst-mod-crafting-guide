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

    ORPHANAGE_1 = "critterlab",

    MADSCIENCE_1 = "madscience_lab",

    FOODPROCESSING_1 = "portableblender_item",

    FISHING_1 = "tacklestation",

    -- TODO: show level on the icon (and in the tooltip)
    HERMITCRABSHOP_1 = "hermitcrab",
    HERMITCRABSHOP_3 = "hermitcrab",
    HERMITCRABSHOP_5 = "hermitcrab",
    HERMITCRABSHOP_7 = "hermitcrab",

    TURFCRAFTING_1 = "turfcraftingstation",

    WINTERSFEASTCOOKING_1 = "wintersfeastoven",

    -- TODO: add support for fishing, offerings
}

local CUSTOM_ICONS_ATLAS = resolvefilepath("images/icons.xml")

local CUSTOM_PREFAB_ICONS = {
    hermitcrab = true,
    critterlab = true,
    moon_altar = true,
    ancient_altar_broken = true,
    ancient_altar = true,
}

local ItemsGroupingType = {
    TAB = "TAB",
}

local TabKey = {
    INFO = "INFO",
    RECIPES = "RECIPES",
}

local RECIPES_COLUMNS_COUNT = 4

local RECIPE_WIDTH = 160
local RECIPE_HEIGHT = 240
local RECIPE_SPACING = 5

local ITEM_POPUP_WIDTH = 890
local ITEM_POPUP_HEIGHT = 500

local VISIBLE_RECIPES_ONE_ROW = 1.9
local VISIBLE_RECIPES_MORE_ROWS = 1.65

return {
    BUILDER_TAG_MAP = BUILDER_TAG_MAP,
    REQUIRED_TECH = REQUIRED_TECH,
    CUSTOM_ICONS_ATLAS = CUSTOM_ICONS_ATLAS,
    CUSTOM_PREFAB_ICONS = CUSTOM_PREFAB_ICONS,
    RECIPES_COLUMNS_COUNT = RECIPES_COLUMNS_COUNT,
    RECIPE_WIDTH = RECIPE_WIDTH,
    RECIPE_HEIGHT = RECIPE_HEIGHT,
    RECIPE_SPACING = RECIPE_SPACING,
    ITEM_POPUP_WIDTH = ITEM_POPUP_WIDTH,
    ITEM_POPUP_HEIGHT = ITEM_POPUP_HEIGHT,
    VISIBLE_RECIPES_ONE_ROW = VISIBLE_RECIPES_ONE_ROW,
    VISIBLE_RECIPES_MORE_ROWS = VISIBLE_RECIPES_MORE_ROWS,

    ItemsGroupingType = ItemsGroupingType,
    TabKey = TabKey,
}
