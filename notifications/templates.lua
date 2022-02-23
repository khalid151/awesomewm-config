local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")

local templates = {}

templates.actions = {
    base_layout = wibox.widget {
        spacing = 5,
        layout = wibox.layout.flex.horizontal,
    },
    widget_template = {
        {
            {
                id = 'text_role',
                align = 'center',
                font = beautiful.notification_action_font,
                widget = wibox.widget.textbox,
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
        margins = 5,
        widget = wibox.container.margin,
    },
    widget = naughty.list.actions,
}

templates.notification = {
    {
        {
            -- notification (title, body and icon)
            {
                {
                    {
                        naughty.widget.icon,
                        margins = 5,
                        widget = wibox.container.margin,
                    },
                    forced_width = beautiful.notification_icon_size,
                    halign = 'center',
                    valign = 'top',
                    widget = wibox.container.place,
                },
                {
                    {
                        id = 'notification_title',
                        widget = naughty.widget.title,
                    },
                    naughty.widget.message,
                    spacing = 2,
                    layout = wibox.layout.fixed.vertical,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            nil,
            -- notification actions
            {
                templates.actions,
                left = 10, right = 10,
                widget = wibox.container.margin,
            },
            layout = wibox.layout.align.vertical,
        },
        id = 'background_role',
        widget = naughty.container.background,
        forced_width = beautiful.notification_width,
    },
    strategy = 'min',
    height = beautiful.notification_height,
    widget = wibox.container.constraint,
}

templates.screenshot = {
    {
        {
            {
                id = 'icon',
                widget = wibox.widget.imagebox,
            },
            {
                nil,
                nil,
                {
                    {
                        {
                            {
                                image = beautiful.icons['24x24']['camera'],
                                forced_height = 20,
                                widget = wibox.widget.imagebox,
                            },
                            naughty.widget.title,
                            spacing = 5,
                            layout = wibox.layout.fixed.horizontal,
                        },
                        margins = 5,
                        widget = wibox.container.margin,
                    },
                    bg = beautiful.bg_normal .. "a1",
                    widget = wibox.container.background,
                },
                layout = wibox.layout.align.vertical,
            },
            layout = wibox.layout.stack,
        },
        id = 'background_role',
        forced_width = beautiful.notification_width,
        widget = naughty.container.background,
    },
    strategy = 'max',
    width = beautiful.notification_width,
    widget = wibox.container.constraint,
}

return templates
