local Widget = require("widgets/widget")
local Templates = require("widgets/redux/templates")

local Util = require("CraftingGuide/Util")

require("constants")

local OPTION_WIDTH = 700
local OPTION_HEIGHT = 40
local OPTION_PADDING = 30
local LABEL_WIDTH = OPTION_WIDTH * 0.65
local SPINNER_WIDTH = OPTION_WIDTH - LABEL_WIDTH

--- Settings
local Settings = Class(Widget, function (self)
    Widget._ctor(self, "Settings")

    self.root = self:AddChild(Widget("root"))

    local settings = Util:GetSettingsConfig()

    self.grid = self.root:AddChild(Templates.ScrollingGrid(settings, {
        widget_width = OPTION_WIDTH + OPTION_PADDING,
        widget_height = OPTION_HEIGHT,
        num_visible_rows = 11,
        num_columns = 1,
        item_ctor_fn = function (_, index)
            local widget = Widget("option" .. index)

            widget.background = widget:AddChild(Templates.ListItemBackground(OPTION_WIDTH + OPTION_PADDING, OPTION_HEIGHT))

            widget.option = widget:AddChild(Templates.LabelSpinner("", {}, LABEL_WIDTH, SPINNER_WIDTH, OPTION_HEIGHT))
            widget.option.spinner:EnablePendingModificationBackground()
            widget.option.spinner.OnChanged = function (_, value)
                Util:SetSetting(widget.option.setting.name, value)
            end

            widget.ApplySetting = function (_, setting)
                widget.option.setting = setting

                widget.option.label:SetString(setting.label)
                widget.option.spinner:Show()
                widget.option.spinner:SetOptions(
                    Util:Map(setting.options, function (option)
                        return {
                            data = option.data,
                            text = option.description,
                        }
                    end)
                )
                widget.option.spinner:SetSelected(Util:GetSetting(setting.name))
            end

            return widget
        end,
        apply_fn = function (_, widget, setting)
            if setting then
                widget:Show()
                widget:ApplySetting(setting)
            else
                widget:Hide()
            end
        end,
        scrollbar_offset = 20,
        scrollbar_height_offset = -60,
    }))
end)

return Settings
