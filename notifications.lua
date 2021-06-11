local naughty = require("naughty")
local beautiful = require("beautiful")

local wibox = require("wibox")
local ruled = require("ruled")

-- Config
naughty.config.padding = beautiful.notification_padding
naughty.config.defaults.padding = beautiful.notification_padding
naughty.config.defaults.icon_size = beautiful.notification_icon_size
naughty.config.defaults.max_width = beautiful.notification_width
naughty.config.defaults.width = beautiful.notification_width
naughty.config.defaults.height = beautiful.notification_height
naughty.config.defaults.position = beautiful.notification_position
naughty.config.defaults.shape = beautiful.notification_shape

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

-- Templates
local actions_template = {
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
local notification_template = {
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
                actions_template,
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

-- RULES ----------------------------------------------------------------------
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule = {},
        properties = {
            store = true,
            timeout = 5,
            hover_timeout = 30,
            bg = beautiful.notification_bg_normal,
            fg = beautiful.notification_fg_normal,
            border_width = beautiful.notification_border_width,
            ignore = function() return Vars.do_not_disturb end,
            icon = function(n) return n:get_icon() or beautiful.notification_default_icon end,
            widget_template = notification_template,
        }
    }
    ruled.notification.append_rule {
        rule = { urgency = 'critical' },
        properties = {
            store = false,
            timeout = 0,
            bg = beautiful.notification_bg_critical,
            fg = beautiful.notification_fg_critical,
            icon = function(n) return n:get_icon() or beautiful.notification_error_icon end,
            widget_template = notification_template,
        }
    }
    ruled.notification.append_rule {
        rule = { app_name = "scrot" },
        properties = {
            store = false,
            fg = beautiful.fg_normal,
            widget_template = function(n) return {
                {
                    {
                        {
                            image = n.icon,
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
            } end,
        }
    }
end)

naughty.connect_signal('request::display', function(n)
    local nt = naughty.layout.box { notification = n }

    -- Change title font if set by theme
    if beautiful.notification_title_font then
        local tb = nt.widget:get_children_by_id('notification_title')[1]
        if tb then
            tb:set_font(beautiful.notification_title_font)
        end
    end
end)
