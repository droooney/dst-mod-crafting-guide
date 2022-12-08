name = "Crafting Guide"
description = "This mod helps to find out what you can craft from an item in your inventory or any container"
author = "jimmybaxter"
version = "0.5"
api_version = 10
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {}
forumthread = ""

local string = ""
local keyBindings = {}

for i = 1, 26 do
    local char = string.char(64 + i)

    keyBindings[#keyBindings + 1] = {
        data = "KEY_" .. char,
        description = char,
    }
end

for i = 1, 12 do
    keyBindings[#keyBindings + 1] = {
        data = "KEY_F" .. i,
        description = "F" .. i,
    }
end

keyBindings[#keyBindings + 1] = {
    data = "NONE",
    description = "None",
}

local booleanTranslations = {}

local translations = {
    GROUP_BY_OPTIONS = {},
    CHAR_SPECIFIC_OPTIONS = {},
    SHOW_DESCRIPTION_ON_HOVER_OPTIONS = booleanTranslations,
    AUTOPAUSE_OPTIONS = booleanTranslations,
}

-- en
booleanTranslations.YES = "Yes"
booleanTranslations.NO = "No"

translations.GROUP_BY = "Group By"
translations.GROUP_BY_DESCRIPTION = "Sets what recipes grouping should be based on"

translations.GROUP_BY_OPTIONS.CRAFTING_TAB = "Crafting Filter"
translations.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE = "Recipe Knowledge"
translations.GROUP_BY_OPTIONS.NONE = "None"

translations.CHAR_SPECIFIC = "Character-Specific Recipes"
translations.CHAR_SPECIFIC_DESCRIPTION = "Sets what character-specific recipes should be shown"

translations.CHAR_SPECIFIC_OPTIONS.SHOW_ALL = "Show All"
translations.CHAR_SPECIFIC_OPTIONS.SHOW_MINE = "Show Only Mine"
translations.CHAR_SPECIFIC_OPTIONS.HIDE = "Hide"

translations.SHOW_DESCRIPTION_ON_HOVER = "Show description on hover"

translations.KEY_BINDINGS = "Key Bindings"

translations.KEY_BIND_OPEN_ALL = "All Recipes"
translations.KEY_BIND_OPEN_ALL_DESCRIPTION = "Open the modal with all recipes"

-- ru
if language == "ru" or locale == "ru" then
    booleanTranslations.YES = "Да"
    booleanTranslations.NO = "Нет"

    translations.GROUP_BY = "Группировать по"
    translations.GROUP_BY_DESCRIPTION = "По какому признаку группировать рецепты"

    translations.GROUP_BY_OPTIONS.CRAFTING_TAB = "Фильтру крафта"
    translations.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE = "Знанию рецепта"
    translations.GROUP_BY_OPTIONS.NONE = "Без группировки"

    translations.CHAR_SPECIFIC = "Особые рецепты персонажей"
    translations.CHAR_SPECIFIC_DESCRIPTION = "Видимость особых рецептов персонажей"

    translations.CHAR_SPECIFIC_OPTIONS.SHOW_ALL = "Показывать все"
    translations.CHAR_SPECIFIC_OPTIONS.SHOW_MINE = "Показывать только свои"
    translations.CHAR_SPECIFIC_OPTIONS.HIDE = "Скрыть"

    translations.SHOW_DESCRIPTION_ON_HOVER = "Показывать описание по наведению"

    translations.KEY_BINDINGS = "Клавиши"

    translations.KEY_BIND_OPEN_ALL = "Все рецепты"
    translations.KEY_BIND_OPEN_ALL_DESCRIPTION = "Окрыть диалог со всеми рецептами"
end

configuration_options = {
    {
        name = "GROUP_BY",
        label = translations.GROUP_BY,
        options = {
            {data = "CRAFTING_TAB", description = translations.GROUP_BY_OPTIONS.CRAFTING_TAB},
            {data = "RECIPE_KNOWLEDGE", description = translations.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE},
            {data = "NONE", description = translations.GROUP_BY_OPTIONS.NONE},
        },
        default = "CRAFTING_TAB",
        hover = translations.GROUP_BY_DESCRIPTION,
    },
    {
        name = "CHAR_SPECIFIC",
        label = translations.CHAR_SPECIFIC,
        options = {
            {data = "SHOW_ALL", description = translations.CHAR_SPECIFIC_OPTIONS.SHOW_ALL},
            {data = "SHOW_MINE", description = translations.CHAR_SPECIFIC_OPTIONS.SHOW_MINE},
            {data = "HIDE", description = translations.CHAR_SPECIFIC_OPTIONS.HIDE},
        },
        default = "SHOW_ALL",
        hover = translations.CHAR_SPECIFIC_DESCRIPTION,
    },
    {
        name = "SHOW_DESCRIPTION_ON_HOVER",
        label = translations.SHOW_DESCRIPTION_ON_HOVER,
        options = {
            {data = "YES", description = translations.SHOW_DESCRIPTION_ON_HOVER_OPTIONS.YES},
            {data = "NO", description = translations.SHOW_DESCRIPTION_ON_HOVER_OPTIONS.NO},
        },
        default = "NO",
    },

    {
        name = "",
        label = translations.KEY_BINDINGS,
        options = {{data = 0, description = ""}},
        default = 0,
        hover = "",
    },
    {
        name = "KEY_OPEN_ALL",
        label = translations.KEY_BIND_OPEN_ALL,
        options = keyBindings,
        default = "KEY_F11",
        hover = translations.KEY_BIND_OPEN_ALL_DESCRIPTION,
    },
}
