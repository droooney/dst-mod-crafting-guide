name = "Crafting Guide"
description = "This mod helps to find out what you can craft from an item in your inventory or any container"
author = "jimmybaxter"
version = "0.2"
api_version = 10
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {}
forumthread = ""

local translations = {
    GROUP_BY_OPTIONS = {},
    CHAR_SPECIFIC_OPTIONS = {},
}

-- en
translations.GROUP_BY = "Group By"
translations.GROUP_BY_DESCRIPTION = "Sets what recipes grouping should be based on"

translations.GROUP_BY_OPTIONS.CRAFTING_TAB = "Crafting Tab"
translations.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE = "Recipe Knowledge"
translations.GROUP_BY_OPTIONS.NONE = "None"

translations.CHAR_SPECIFIC = "Character-Specific Recipes"
translations.CHAR_SPECIFIC_DESCRIPTION = "Sets what character-specific recipes should be shown"

translations.CHAR_SPECIFIC_OPTIONS.SHOW_ALL = "Show All"
translations.CHAR_SPECIFIC_OPTIONS.SHOW_MINE = "Show Only Mine"
translations.CHAR_SPECIFIC_OPTIONS.HIDE = "Hide"

-- ru
if language == "ru" or locale == "ru" then
    translations.GROUP_BY = "Группировать по"
    translations.GROUP_BY_DESCRIPTION = "По какому признаку группировать рецепты"

    translations.GROUP_BY_OPTIONS.CRAFTING_TAB = "Вкладке крафта"
    translations.GROUP_BY_OPTIONS.RECIPE_KNOWLEDGE = "Знанию рецепта"
    translations.GROUP_BY_OPTIONS.NONE = "Без группировки"

    translations.CHAR_SPECIFIC = "Особые рецепты персонажей"
    translations.CHAR_SPECIFIC_DESCRIPTION = "Видимость особых рецептов персонажей"

    translations.CHAR_SPECIFIC_OPTIONS.SHOW_ALL = "Показывать все"
    translations.CHAR_SPECIFIC_OPTIONS.SHOW_MINE = "Показывать только свои"
    translations.CHAR_SPECIFIC_OPTIONS.HIDE = "Скрыть"
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
}
