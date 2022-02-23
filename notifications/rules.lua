local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")
local insert = require("utils.helper").insert_into_table_by_id

local templates = require("notifications.templates")

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
            widget_template = templates.notification,
            callback = function(n)
                awful.spawn.easy_async("date +'%I:%M %p'", function(o) n.time = o end)
            end
        }
    }
    ruled.notification.append_rule {
        rule = { urgency = 'critical' },
        properties = {
            store = false,
            timeout = 0,
            ignore = false,
            bg = beautiful.notification_bg_critical,
            fg = beautiful.notification_fg_critical,
            icon = function(n) return n:get_icon() or beautiful.notification_error_icon end,
            widget_template = templates.notification,
        }
    }
    ruled.notification.append_rule {
        rule = { app_name = "gopass" },
        properties = {
            store = false,
        }
    }
    ruled.notification.append_rule {
        rule = { app_name = "scrot" },
        properties = {
            store = false,
            fg = beautiful.fg_normal,
            widget_template = function(n)
                local template = templates.screenshot
                insert(templates.screenshot, { image = n.icon }, 'icon')
                return template
            end,
        }
    }
end)
