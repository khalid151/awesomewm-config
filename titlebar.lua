local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local titlebar = {}

titlebar.generate = function(c)
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end))

    -- To get hover in\out events out of titlebar
    local titlebar_layout = wibox.layout.align.horizontal()

    -- Widgets that are supposed to be toggled
    local lhs_widgets = wibox.widget {
        {
            awful.titlebar.widget.stickybutton(c),
            margins = 5,
            layout = wibox.container.margin
        },
        layout = wibox.layout.fixed.horizontal
    }
    local rhs_widgets = wibox.widget {
        {
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            spacing = beautiful.titlebar_icon_spacing,
            layout = wibox.layout.fixed.horizontal
        },
        margins = beautiful.titlebar_icon_margins,
        layout = wibox.container.margin
    }

    -- if enabled, only show center widget (which is title)
    if beautiful.titlebar_autohide_controls then
        lhs_widgets.visible = false
        rhs_widgets.visible = false
        titlebar_layout:connect_signal("mouse::enter", function()
            lhs_widgets.visible = true
            rhs_widgets.visible = true
        end)
        titlebar_layout:connect_signal("mouse::leave", function()
            lhs_widgets.visible = false
            rhs_widgets.visible = false
        end)
    end

    local layout = {
        {
            lhs_widgets,
            nil,
            rhs_widgets,
            layout = titlebar_layout,
        },
        -- Have titlebar and constraint it to size, to be in center without affecting controls
        {
            {
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c),
                buttons = buttons,
            },
            --left = beautiful.titlebar_size * #lhs_widgets.children, TODO: better centering
            left = beautiful.titlebar_size * #rhs_widgets.widget.children,
            right = beautiful.titlebar_size * #rhs_widgets.widget.children,
            widget = wibox.container.margin,
        },
        layout = wibox.layout.stack,
    }
    return layout
end

return titlebar
