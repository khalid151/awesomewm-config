local awful = require("awful")
local wibox = require("wibox")
local widgets = require("widgets")
local gears = require("gears")
local naughty = require("naughty")

local beautiful = require("beautiful")

local toggle_dnd = function()
    Vars.do_not_disturb = not Vars.do_not_disturb
    awesome.emit_signal("modules::notification_dnd")
end

local dismiss_notifications = function()
    naughty.destroy_all_notifications()
    awesome.emit_signal("modules::notification_clear")
end

local default_template = {
    {
        -- the whole notification
        {
            {
                {
                    {
                        id = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
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
                    id = 'title_role',
                    font = beautiful.notification_title_font,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'message_role',
                    font = beautiful.notification_font,
                    widget = wibox.widget.textbox,
                },
                spacing = 2,
                layout = wibox.layout.fixed.vertical,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        {
            {
                {
                    id = 'time_role',
                    widget = wibox.widget.textbox,
                },
                valign = 'top',
                halign = 'right',
                widget = wibox.container.place,
            },
            right = 2,
            widget = wibox.container.margin,
        },
        layout = wibox.layout.stack,
    },
    shape = beautiful.notification_shape,
    fg = beautiful.notification_fg_normal,
    bg = beautiful.notification_bg_normal,
    forced_width = beautiful.notification_width,
    forced_height = beautiful.notification_height,
    widget = wibox.container.background,
}

return function(args)
    -- Widgets
    local header = {
        {
            {
                text = " Notification Center",
                font = beautiful.notification_center_header_font,
                widget = wibox.widget.textbox,

            },
            nil,
            {
                {
                    {
                        image = args.icon_dnd
                            or beautiful.notification_center_header_icon_dnd,
                        widget = wibox.widget.imagebox,
                        buttons = {awful.button({}, 1, nil, toggle_dnd)},
                    },
                    {
                        image = args.icon_dismiss
                            or beautiful.notification_center_header_icon_dismiss,
                        widget = wibox.widget.imagebox,
                        buttons = {awful.button({}, 1, nil, dismiss_notifications)},
                    },
                    spacing = 2,
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = 5,
                widget = wibox.container.margin,
            },
            layout = wibox.layout.align.horizontal,
        },
        bg = beautiful.notification_center_header_bg,
        fg = beautiful.notification_center_header_fg,
        forced_height = beautiful.notification_center_header_height,
        widget = wibox.container.background,
    }

    local notifications = widgets.scrollbox {
        width = beautiful.notification_width + 10,
        item_height = beautiful.notification_height,
        spacing = 5,
        --bg = "transparent",
        height = (args.height or beautiful.notification_center_height) - beautiful.notification_center_header_height,
    }

    local no_notification_text = wibox.widget {
        {
            text = "No unread notifications",
            widget = wibox.widget.textbox,
        },
        halign = 'center',
        valign = 'center',
        widget = wibox.container.place,
    }

    local popup = awful.popup {
        widget = {
            {
                header,
                {
                    {
                        notifications,
                        no_notification_text,
                        layout = wibox.layout.stack,
                    },
                    margins = 5,
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.vertical,
            },
            bg = beautiful.notification_center_bg,
            forced_width = beautiful.notification_width + 10,
            forced_height = args.height or beautiful.notification_center_height,
            widget = wibox.container.background,
        },
        x = args.x,
        y = args.y,
        shape = args.shape,
        placement = args.placement,
        screen = args.screen,
        visible = false,
        ontop = true,
        bg = "transparent",
    }

    local widget = wibox.widget {
        icon_empty = args.icon_empty or beautiful.notification_center_icon_empty,
        icon_unread = args.icon_unread or beautiful.notification_center_icon_unread,
        icon_dnd_empty = args.icon_dnd_empty or beautiful.notification_center_icon_dnd_empty,
        icon_dnd_unread = args.icon_dnd_unread or beautiful.notification_center_icon_dnd_unread,
        widget = wibox.widget.imagebox,
    }

    widget.image = widget.icon_empty

    awful.tooltip {
        objects = {widget},
        mode = 'mouse',
        margins = 5,
        delay_show = 0.5,
        preferred_positions = "bottom",
        preferred_alignments = "middle",
        timer_function = function() return "Unread: " .. #notifications.widget:get_children() end
    }

    local add_notification = function(n)
        if n.store then
            local notification = wibox.widget(args.notification_template or
            default_template)

            for k,v in pairs {
                icon_role = {'icon', 'image'},
                title_role = {'title', 'text'},
                message_role = {'message', 'text'},
                time_role = {'time', 'text'},
            } do
                local w = notification:get_children_by_id(k)[1]
                if w then
                    w[v[2]] = n[v[1]]
                end
            end

            notification.id = n.id

            -- TODO: handle buttons
            notification:connect_signal("button::release", function(_, _, _, button)
                if button == 3 then
                    notifications:remove_widget(notification)
                    if #notifications.widget:get_children() == 0 then
                        popup.visible = false
                    end
                    widget:emit_signal("widget::update_icon")
                end
            end)

            notifications:add_widget(notification)
            widget:emit_signal("widget::update_icon")
        end
    end

    -- Signals
    widget:connect_signal("button::release", function(_, _, _, button)
        if button == 1 then
            popup.visible = not popup.visible
        elseif button == 3 then
            toggle_dnd()
        end
    end)

    widget:connect_signal("widget::update_icon", function()
        local count = #notifications.widget:get_children()
        widget.image = widget[string.format('icon_%s%s',
            Vars.do_not_disturb and 'dnd_' or '',
            count > 0 and 'unread' or 'empty'
        )]
        no_notification_text.visible = not (count > 0)
    end)

    naughty.connect_signal("added", function(n)
        if Vars.do_not_disturb then
            gears.timer {
                single_shot = true,
                timeout = 0.5,
                autostart = true,
                callback = function() add_notification(n) end,
            }
        end
    end)

    naughty.connect_signal("destroyed", function(n, context)
        -- Store notification if it was expired
        if context == 1 and not Vars.do_not_disturb then
            add_notification(n)
        end
    end)

    awesome.connect_signal("modules::notification_clear", function()
        notifications:remove_all_widgets()
        popup.visible = false
        widget:emit_signal("widget::update_icon")
    end)

    awesome.connect_signal("modules::notification_dnd", function()
        widget:emit_signal("widget::update_icon")
    end)

    awesome.connect_signal("modules::notification_center_toggle", function()
        popup.visible = not popup.visible
    end)

    return widget
end
