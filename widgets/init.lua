local gears = require("gears")
local wibox = require("wibox")

local widgets = {
    battery = require("widgets.battery"),
    brightness = require("widgets.brightness"),
    imagebox_button = require("widgets.imagebox_button"),
    menu = require("widgets.menu"),
    separator = require("widgets.separator"),
    space = wibox.widget.textbox(" "),
    systray = require("widgets.systray"),
    taglist = require("widgets.taglist"),
    textclock = require("widgets.textclock"),
    toggle_widget = require("widgets.toggle_widget"),
    volume = require("widgets.volume"),
}

gears.timer {
    autostart = true,
    call_now = true,
    timeout = 2,
    callback = function()
        for _,w in ipairs { "battery", "brightness",  "volume" } do
            awesome.emit_signal("widgets::" .. w)
        end
    end
}

return widgets
