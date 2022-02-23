local naughty = require("naughty")
local beautiful = require("beautiful")

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

-- Load rules
require("notifications.rules")

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
