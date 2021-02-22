local Widget = require("widgets/widget")

local GeneralInfo = require("./GeneralInfo")
local CraftingRecipe = require("./CraftingRecipe")

local Constants = require("./Constants")

--- CraftingWidgetRow
-- @param options.owner      {Player}                    player instance
-- @param options.closePopup {() => void}                close item popup
-- @param options.chooseItem {(prefab: Prefab) => void}  choose item callback
local CraftingWidgetRow = Class(Widget, function (self, options)
    Widget._ctor(self, "CraftingWidgetRow")

    self.root = self:AddChild(Widget("root"))
    self.generalInfo = self.root:AddChild(GeneralInfo())
    self.groupHeader = self.root:AddChild(Widget("groupHeader"))
    self.recipeRow = self.root:AddChild(Widget("recipeRow"))

    self.recipeRow.items = {}

    for i = 1, Constants.RECIPES_COLUMNS_COUNT, 1 do
        table.insert(self.recipeRow.items, CraftingRecipe({
            owner = options.owner,
            closePopup = options.closePopup,
            chooseItem = options.chooseItem,
        }))
    end
end)

--- CraftingWidgetRow:SetRowData
-- rowData.row        {GeneralInfoRow | GroupHeaderRow | RecipeRow}  actual row data
-- rowData.pagePrefab {Prefab}                                       item page prefab
function CraftingWidgetRow:SetRowData(rowData)
    self.generalInfo:Hide()
    self.groupHeader:Hide()
    self.recipeRow:Hide()

    if not rowData then
        return
    end

    local row = rowData.row
    local pagePrefab = rowData.pagePrefab

    if row.type == Constants.ItemListType.GENERAL_INFO then
        self.generalInfo:Show()
    elseif row.type == Constants.ItemListType.GROUP_HEADER then
        self.groupHeader:Show()
    else
        self.recipeRow:Show()

        for i, recipe in row.recipes do
            self.recipeRow.items[i].SetRecipeData({
                recipe = recipe,
                pagePrefab = pagePrefab,
            })
        end
    end
end

return CraftingWidgetRow
