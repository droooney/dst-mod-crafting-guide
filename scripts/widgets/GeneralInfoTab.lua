local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")
local Image = require("widgets/image")
local Text = require("widgets/text")

local Constants = require("./Constants")
local Util = require("./Util")

require("constants")
require("fonts")

local GeneralInfoTab = Class(Widget, function (self, options)
    Widget._ctor(self, "GeneralInfoTab")

    self.root = self:AddChild(Widget("root"))

    self.imageBg = self.root:AddChild(Image("images/global_redux.xml", "char_selection_hover.tex"))
    self.title = self.root:AddChild(Text(UIFONT, 40))
    self.description = self.root:AddChild(Text(UIFONT, 24))

    self.imageBg:SetPosition(350, 100)
    self.imageBg:SetScale(1.25)

    self.title:SetPosition(-100, 200)

    self.description:SetPosition(-Constants.ITEM_POPUP_WIDTH / 2 + 75, 150)
    -- self.description:SetHAlign(ANCHOR_LEFT)
end)

function GeneralInfoTab:SetPrefab(prefab)
    self.title:SetString(Util:GetPrefabString(prefab))
    self.description:SetString(STRINGS.RECIPE_DESC[string.upper(prefab)] or "")
end

return GeneralInfoTab
