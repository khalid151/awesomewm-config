-- TODO: fix multiple monitors
-- Enable fading in\out for bar background
local awestore = require("awestore")
local awful = require("awful")
local beautiful = require("beautiful")

-- Opacity values
local opacity = {
    high = beautiful.bar_max_opacity or 255,
    low = beautiful.bar_min_opacity or 0,
}

-- Keep track of screen
local current_screen = awful.screen.focused()

local emit_gaps_signal = function() awesome.emit_signal("check_gaps") end
emit_gaps_signal()

-- Tween opacity values
local opacity_tween = awestore.tweened(beautiful.bar_min_opacity, {
    duration = beautiful.bar_fade_duration or 200,
    easing = awestore.easing.cubic_in_out,
})

opacity_tween:subscribe(function(v)
    current_screen.bar.bg = string.format("%s%x", beautiful.bar_bg, math.floor(v))
end)

-- Function to change opacity
local set_opacity = function(screen, value)
    current_screen = screen
    opacity_tween:set(value)
end

-- To make it easier to set all clients on screen with a check function
-- client is passed as an arugment for the check function
local set_clients_on_screen = function (screen, check)
    local state = true
    local clients = screen.clients
    for _,c in ipairs(clients) do
        if check(c) then
            set_opacity(screen, opacity.high)
            state = true
            break
        else
            state = false
        end
    end
    if not state then
        set_opacity(screen, opacity.low)
    end
end

-- Connect signals
client.connect_signal("request::manage", emit_gaps_signal)
client.connect_signal("request::unmanage", emit_gaps_signal)
tag.connect_signal("property::layout", emit_gaps_signal)
tag.connect_signal("property::tag_changed", emit_gaps_signal)
tag.connect_signal("property::useless_gap", emit_gaps_signal)
client.connect_signal("property::floating", emit_gaps_signal)
client.connect_signal("property::minimized", emit_gaps_signal)
client.connect_signal("property::maximized", function(c)
    if c.maximized then
        set_opacity(c.screen, opacity.high)
    else
        awesome.emit_signal("check_gaps")
    end
end)

awesome.connect_signal("check_gaps", function()
    local screen = awful.screen.focused()
    local current_tag = screen.selected_tag
    local layout_name = current_tag.layout.name
    current_tag.useless_gap = current_tag.useless_gap or beautiful.useless_gap

    if #screen.clients > 0 then
        if layout_name == "floating" then
            set_clients_on_screen(screen, function(c) return c.maximized end)
        else
            if current_tag.useless_gap > 0 then
                set_clients_on_screen(screen, function(c) return c.maximized end)
            else
                if current_tag.master_fill_policy == "master_width_factor"
                    and #screen.clients == 1
                    and layout_name ~= "max" then
                    set_opacity(screen, opacity.low)
                else
                    set_clients_on_screen(screen, function(c)
                        return not c.floating or c.maximized
                    end)
                end

            end
        end
    else
        set_opacity(screen, opacity.low)
    end
end)
