local awful = require("awful")
local wibox = require("wibox")
local widgets = require("widgets")
local gears = require("gears")
local naughty = require("naughty")
local connect_hover_signal = require("utils.helper").connect_hover_signal

local beautiful = require("beautiful")

local toggle_dnd = function(w)
    Vars.do_not_disturb = not Vars.do_not_disturb
    awesome.emit_signal("modules::notification_dnd")
end

local dismiss_notifications = function()
    naughty.destroy_all_notifications()
    awesome.emit_signal("modules::notification_clear")
end

local default_template = {
    {
        {
            -- app name and time
            {
                id = "notification_info",
                {
                    forced_width = 5,
                    widget = wibox.container.background,
                },
                {
                    id = "app_name_role",
                    font = "sans bold 8",
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'time_role',
                    font = "sans 8",
                    widget = wibox.widget.textbox,
                },
                opacity = 0.9,
                forced_height = 12,
                spacing = 5,
                layout = wibox.layout.fixed.horizontal,
            },
            -- rest of the notification
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
                        {
                            id = 'message_role',
                            font = beautiful.notification_font,
                            widget = wibox.widget.textbox,
                        },
                        width = beautiful.notification_width - beautiful.notification_icon_size - 25,
                        widget = wibox.container.constraint,
                    },
                    spacing = 2,
                    layout = wibox.layout.fixed.vertical,
                },
                layout = wibox.layout.align.horizontal,
            },
            layout = wibox.layout.fixed.vertical,
        },
        nil,
        {
            id = "dismiss_button",
            text = "",
            opacity = 0.9,
            forced_width = 15,
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.align.horizontal,
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
    local dnd_toggle_button = wibox.widget {
        text = "",
        font = "monospace " .. (args.icon_size or 20) - 2,
        widget = wibox.widget.textbox,
        buttons = {awful.button({}, 1, nil, toggle_dnd)},
        opacity = 0.6,
    }
    local dismiss_all_button = wibox.widget {
        text = "",
        font = "monospace " .. (args.icon_size or 20),
        widget = wibox.widget.textbox,
        buttons = {awful.button({}, 1, nil, dismiss_notifications)},
        opacity = 0.6,
    }
    connect_hover_signal {
        widgets = { dnd_toggle_button, dismiss_all_button },
        enter_action = function(w) w.opacity = 1 end,
        leave_action = function(w) w.opacity = 0.6 end,
    }
    local header = {
        {
            {
                text = " Notifications",
                font = beautiful.notification_center_header_font,
                widget = wibox.widget.textbox,

            },
            nil,
            {
                {
                    dnd_toggle_button,
                    dismiss_all_button,
                    spacing = 5,
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
        visible =  not (args.autohide or false),
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

            local dismiss_this_notification = function()
                notifications:remove_widget(notification)
                if #notifications.widget:get_children() == 0 then
                    popup.visible = false
                end
                widget:emit_signal("widget::update_icon")
            end

            for k,v in pairs {
                icon_role = {'icon', 'image'},
                app_name_role = {'app_name', 'text'},
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

            local info = notification:get_children_by_id("notification_info")[1]
            info.opacity = 0.5
            connect_hover_signal {
                widget = notification,
                enter_action = function() info.opacity = 1 end,
                leave_action = function() info.opacity = 0.5 end,
            }

            -- TODO: handle buttons
            local dismiss_button = notification:get_children_by_id("dismiss_button")[1]
            dismiss_button.buttons = { awful.button({ }, 1, dismiss_this_notification) }

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
        if args.autohide then
            widget.visible = count > 0 or Vars.do_not_disturb
        end
        dnd_toggle_button.text = Vars.do_not_disturb and "" or ""
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
