local Widget = require("widgets/widget")

require("constants")

--- Settings
local Settings = Class(Widget, function (self)
    Widget._ctor(self, "Settings")

    self.root = self:AddChild(Widget("root"))
end)

return Settings
