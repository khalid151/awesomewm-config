local wibox = require("wibox")

-- args:
--      bg = background color
--      widget = child widget to toggle
--      shape = shape of widget
--      spacing = spacing between the toggle button and widget
--      swap = swap location of toggle button and widget
return function(args)
    local bg = args.bg or "transparent"
    local toggle = wibox.widget {
        image = args.show_icon,
        widget = wibox.widget.imagebox
    }

    args.widget.visible = false

    local widget = wibox.widget {
        {
            id = 'layout_widget',
            toggle,
            args.widget,
            spacing = args.spacing,
            layout = wibox.layout.fixed.horizontal
        },
        bg = bg,
        shape = args.shape,
        widget = wibox.container.background
    }

    toggle:connect_signal("button::release", function(w)
        args.widget.visible = not args.widget.visible
        w.image = args.widget.visible and args.hide_icon or args.show_icon
        if args.bg then
            widget.bg = args.widget.visible and bg or "transparent"
        end
    end)

    -- Swap the location of widget and toggle button
    if args.swap then
        widget.layout_widget:swap(1, 2)
    end

    return widget
end
