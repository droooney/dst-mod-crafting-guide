local MOD_OPTIONS = {
    GROUP_BY = "GROUP_BY",
    CHAR_SPECIFIC = "CHAR_SPECIFIC",
    HOVER_SHOW_DESCRIPTION = "HOVER_SHOW_DESCRIPTION",

    KEY_OPEN_ALL = "KEY_OPEN_ALL",
}

local GROUP_BY_OPTIONS = {
    CRAFTING_TAB = "CRAFTING_TAB",
    RECIPE_KNOWLEDGE = "RECIPE_KNOWLEDGE",
    NONE = "NONE",
}

local GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS = {
    KNOWN_RECIPE = "KNOWN_RECIPE",
    UNKNOWN_RECIPE = "UNKNOWN_RECIPE",
    RARE_BLUEPRINT = "RARE_BLUEPRINT",
    NO_BLUEPRINT = "NO_BLUEPRINT",
}

local CHAR_SPECIFIC_OPTIONS = {
    SHOW_ALL = "SHOW_ALL",
    SHOW_MINE = "SHOW_MINE",
    HIDE = "HIDE",
}

local BUILDER_TAG_MAP = {
    alchemist = "wilson",
    balloonomancer = "wes",
    battlesinger = "wathgrithr",
    battlesongcontainermaker = "wathgrithr",
    battlesonginstantrevivemaker = "wathgrithr",
    battlesonglunaralignedmaker = "wathgrithr",
    battlesongshadowalignedmaker = "wathgrithr",
    berrybushcrafter = "wormwood",
    bookbuilder = "wickerbottom",
    carratcrafter = "wormwood",
    clockmaker = "wanda",
    elixirbrewer = "wendy",
    fire_mastery_1 = "willow",
    fruitdragoncrafter = "wormwood",
    gem_alchemistI = "wilson",
    gem_alchemistII = "wilson",
    gem_alchemistIII = "wilson",
    ghostlyfriend = "wendy",
    handyperson = "winona",
    ick_alchemistI = "wilson",
    ick_alchemistII = "wilson",
    ick_alchemistIII = "wilson",
    juicyberrybushcrafter = "wormwood",
    leifidolcrafter = "woodie",
    lightfliercrafter = "wormwood",
    lureplantcrafter = "wormwood",
    masterchef = "warly",
    merm_builder = "wurt",
    ore_alchemistI = "wilson",
    ore_alchemistII = "wilson",
    ore_alchemistIII = "wilson",
    pebblemaker = "walter",
    pinetreepioneer = "walter",
    plantkin = "wormwood",
    professionalchef = "warly",
    pyromaniac = "willow",
    reedscrafter = "wormwood",
    saddlewathgrithrmaker = "wathgrithr",
    saplingcrafter = "wormwood",
    shadowmagic = "waxwell",
    skill_wilson_allegiance_lunar = "wilson",
    skill_wilson_allegiance_shadow = "wilson",
    spearwathgrithrlightningmaker = "wathgrithr",
    spiderwhisperer = "webber",
    strongman = "wolfgang",
    syrupcrafter = "wormwood",
    upgrademoduleowner = "wx78",
    valkyrie = "wathgrithr",
    wathgrithrimprovedhatmaker = "wathgrithr",
    wathgrithrshieldmaker = "wathgrithr",
    werehuman = "woodie",
    wolfgang_coach = "wolfgang",
    wolfgang_dumbbell_crafting = "wolfgang",
    woodcarver1 = "woodie",
    woodcarver2 = "woodie",
    woodcarver3 = "woodie",
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
    CELESTIAL_3 = "moon_altar",

    MOON_ALTAR_2 = "moon_altar",

    CARTOGRAPHY_2 = "cartographydesk",

    SHADOW_3 = "waxwelljournal",

    SEAFARING_1 = "seafaring_prototyper",
    SEAFARING_2 = "seafaring_prototyper",

    SCULPTING_1 = "sculptingtable",
    SCULPTING_2 = "sculptingtable",

    ORPHANAGE_1 = "critterlab",
    -- TODO
    PERDOFFERING_1 = nil,
    PERDOFFERING_3 = "perdshrine",
    WARGOFFERING_3 = "wargshrine",
    PIGOFFERING_3 = "pigshrine",
    CARRATOFFERING_3 = "yotc_carratshrine",
    BEEFOFFERING_3 = "yotb_beefaloshrine",
    CATCOONOFFERING_3 = "yot_catcoonshrine",
    RABBITOFFERING_3 = "yotr_rabbitshrine",
    DRAGONOFFERING_3 = "yotd_dragonshrine",

    MADSCIENCE_1 = "madscience_lab",
    CARNIVAL_PRIZESHOP_1 = "carnival_prizebooth",
    CARNIVAL_HOSTSHOP_1 = "carnival_host",
    CARNIVAL_HOSTSHOP_3 = "carnival_host",

    FOODPROCESSING_1 = "portableblender_item",
    FISHING_1 = "tacklestation",
    FISHING_2 = nil,

    -- TODO: show level on the icon (and in the tooltip)
    HERMITCRABSHOP_1 = "hermitcrab",
    HERMITCRABSHOP_3 = "hermitcrab",
    HERMITCRABSHOP_5 = "hermitcrab",
    HERMITCRABSHOP_7 = "hermitcrab",

    TURFCRAFTING_1 = "turfcraftingstation",
    TURFCRAFTING_2 = "turfcraftingstation",
    MASHTURFCRAFTING_2 = "turfcraftingstation",

    WINTERSFEASTCOOKING_1 = "wintersfeastoven",

    SPIDERCRAFT_1 = "spider",

    ROBOTMODULECRAFT_1 = "wx78_scanner_item",
    BOOKCRAFT_1 = "bookstation",

    LUNARFORGING_1 = "lunar_forge",
    LUNARFORGING_2 = "lunar_forge",

    SHADOWFORGING_1 = "shadow_forge",
    SHADOWFORGING_2 = "shadow_forge",

    CARPENTRY_2 = "carpentry_station",

    -- TODO: add support for events
}

local REQUIRED_SPIDER = {
    mutator_warrior = "spider_warrior",
    mutator_dropper = "spider_dropper",
    mutator_hider = "spider_hider",
    mutator_spitter = "spider_spitter",
    mutator_moon = "spider_moon",
    mutator_healer = "spider_healer",
    mutator_water = "spider_water",
}

local REQUIRED_SCANNING = {
    wx78module_maxhealth = {"spider"},
    wx78module_maxhealth2 = {"spider_healer"},
    wx78module_maxsanity1 = {"butterfly", "moonbutterfly"},
    wx78module_maxsanity = {"crawlinghorror", "terrorbeak", "oceanhorror"},
    wx78module_bee = {"beequeen"},
    wx78module_music = {"crabking", "hermitcrab"},
    wx78module_maxhunger1 = {"hound"},
    wx78module_maxhunger = {"slurper", "bearger"},
    wx78module_movespeed = {"rabbit"},
    wx78module_movespeed2 = {"minotaur", "rook", "rook_nightmare"},
    wx78module_heat = {"dragonfly", "firehound"},
    wx78module_cold = {"deerclops", "icehound"},
    wx78module_taser = {"lightninggoat"},
    wx78module_nightvision = {"mole"},
    wx78module_light = {"worm", "lightflier", "squid"},
}

local CUSTOM_ICONS_ATLAS = resolvefilepath("images/CraftingGuide/icons.xml")

local CUSTOM_PREFAB_ICONS = {
    "hermitcrab",
    "critterlab",
    "moon_altar",
    "ancient_altar_broken",
    "ancient_altar",
    "carnival_prizebooth",
    "lunar_forge",
    "shadow_forge",
    "carnival_host",
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

local INGREDIENT_BASE_SIZE = 67

return {
    MOD_OPTIONS = MOD_OPTIONS,
    GROUP_BY_OPTIONS = GROUP_BY_OPTIONS,
    GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS = GROUP_BY_RECIPE_KNOWLEDGE_OPTIONS,
    CHAR_SPECIFIC_OPTIONS = CHAR_SPECIFIC_OPTIONS,

    BUILDER_TAG_MAP = BUILDER_TAG_MAP,
    REQUIRED_TECH = REQUIRED_TECH,
    REQUIRED_SPIDER = REQUIRED_SPIDER,
    REQUIRED_SCANNING = REQUIRED_SCANNING,
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
    INGREDIENT_BASE_SIZE = INGREDIENT_BASE_SIZE,

    TabKey = TabKey,
}
