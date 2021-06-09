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

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

-- Create a function so it can be reused later for other templates
local actions_template = function(fg, bg, vertical)
    return {
        widget = naughty.list.actions,
        style = {
            underline_normal = false,
            underline_selected = false,
        },
        base_layout = wibox.widget {
            spacing = 5,
            layout = wibox.layout.flex[vertical and 'vertical' or 'horizontal'],
        },
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        align = 'center',
                        widget = wibox.widget.textbox,
                    },
                    margins = 5,
                    widget = wibox.container.margin,
                },
                widget = wibox.container.background,
                bg = bg,
                fg = fg,
                shape = beautiful.rounded_rect,
            },
            margins = 5,
            widget = wibox.container.margin,
        },
    }
end

local notification_template = function(args)
    return {
        {
            {
                {
                    {
                        {
                            {
                                resize_strategy = 'scale',
                                image = args.icon, -- If this template was reused
                                widget = args.icon and wibox.widget.imagebox or naughty.widget.icon,
                            },
                            forced_height = 48,
                            forced_width = 48,
                            widget = wibox.container.background,
                        },
                        margins = 7,
                        right = 0,
                        widget = wibox.container.margin,
                    },
                    {
                        {
                            {
                                font = args.font,
                                text = args.title,
                                widget = wibox.widget.textbox,
                            },
                            {
                                font = beautiful.notification_font,
                                text = args.message,
                                widget = args.message and wibox.widget.textbox or naughty.widget.message,
                            },
                            wibox.widget.textbox(" "),
                            layout = wibox.layout.fixed.vertical,
                        },
                        fg = args.fg,
                        widget = wibox.container.background,
                    },
                    spacing = 6,
                    layout = wibox.layout.fixed.horizontal,
                },
                nil,
                {
                    actions_template(args.bg, args.fg .. 'de'),
                    left = 15,
                    right = 15,
                    widget = wibox.container.margin
                },
                spacing = 10,
                layout = wibox.layout.align.vertical
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
        width = beautiful.notification_width,
        forced_width = beautiful.notification_width,
        widget = wibox.container.constraint,
    }
end

local scrot_template = function(n)
    return {
        {
            {
                {
                    resize_strategy = 'scale',
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
                                wibox.widget.textbox("Screenshot taken"),
                                spacing = 5,
                                layout = wibox.layout.fixed.horizontal,
                            },
                            margins = 5,
                            widget = wibox.container.margin,
                        },
                        bg = beautiful.notification_fg_normal .. "ce",
                        widget = wibox.container.background,
                    },
                    layout = wibox.layout.align.vertical,
                },
                layout = wibox.layout.stack,
            },
            input_passthrough = true,
            id = 'background_role',
            widget = wibox.container.background,
        },
        width = beautiful.notification_width,
        forced_width = beautiful.notification_width,
        widget = wibox.container.constraint,
    }
end

-- RULES ----------------------------------------------------------------------
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule = {},
        properties = {
            timeout = 5,
            hover_timeout = 0,
            bg = beautiful.notification_bg_normal,
            fg = beautiful.notification_fg_normal,
            border_width = beautiful.notification_border_width,
            callback = function(n)
                n.store = true
                n.icon = n:get_icon() or beautiful.notification_default_icon
            end,
        }
    }
    ruled.notification.append_rule {
        rule = { app_name = "gopass" },
        properties = {
            callback = function(n)
                n.store = false
            end,
        }
    }
    ruled.notification.append_rule {
        rule = { urgency = 'critical' },
        properties = {
            bg = beautiful.notification_bg_critical,
            fg = beautiful.notification_fg_critical,
            timeout = 0,
            callback = function(n)
                n.store = false
                n.icon = n:get_icon() or beautiful.notification_error_icon
            end,
        }
    }
    ruled.notification.append_rule {
        rule = { app_name = "scrot" },
        properties = {
            store = false,
            callback = function(n)
                n.widget_template = scrot_template(n)
            end,
        }
    }
end)

naughty.connect_signal('request::display', function(n)
    if not Vars.do_not_disturb or n.urgency == "critical" then
        naughty.layout.box {
            notification = n,
            widget_template = n.widget_template or notification_template {
                font = beautiful.notification_font_title,
                fg = n:get_fg(),
                title = n:get_title(),
            },
            shape = beautiful.rounded_rect,
        }
    end
end)
