local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

-- helpers
local add_keybindings = require("utils.helper").add_keybindings
local spawn = function(cmd, signal)
    return function()
        awful.spawn(cmd)
        if signal ~= nil then
            awesome.emit_signal(signal)
        end
    end
end
local scrot = function(args)
    local flags = args or ''
    local screenshot_path = os.getenv("HOME") .. '/Pictures/Screenshots/' .. os.date('Screenshot_%Y%m%d_%H%M%S.png')
    awful.spawn("scrot " .. flags .. ' ' .. screenshot_path)
    gears.timer {
        autostart = true,
        single_shot = true,
        timeout = 0.3,
        callback = function()
            naughty.notify({title = "Screenshot Taken", icon = screenshot_path, icon_size = 160})
        end,
    }
end
local keys = {
    alt = "Mod1",
    control = "Control",
    super = "Mod4",
    shift = "Shift",
    tab = "Tab",
}

-- Constants
local GAPS_INCREAMENT = 5
local WIDTH_FACTOR = 0.05

-- Global keys
awful.keyboard.append_global_keybindings(add_keybindings {
    -- Keybinding: { keys, action, description, group }
    -- Layout
    {"super+space", function() awful.layout.inc(1) end, "Select next layout", "Layout"},
    {"super+shift+space", function() awful.layout.inc(-1) end, "Select previous layout", "Layout"},
    {"super+equal", function() awful.tag.incgap(GAPS_INCREAMENT, nil) end, "Increment gaps size for the current tag", "Layout"},
    {"super+minus", function() awful.tag.incgap(-1 * GAPS_INCREAMENT, nil) end, "Decrement gap size for the current tag", "Layout"},
    {"super+l", function() awful.tag.incmwfact(WIDTH_FACTOR) end, "Increase master width factor", "Layout"},
    {"super+h", function() awful.tag.incmwfact(-1 * WIDTH_FACTOR) end, "Decrease master width factor", "Layout"},
    {"super+shift+l", function() awful.tag.incnmaster(1, nil, true) end, "Increase number of master clients", "Layout"},
    {"super+shift+h", function() awful.tag.incnmaster(-1, nil, true) end, "Decrease number of master clients", "Layout"},
    {"super+control+l", function() awful.tag.incncol(1, nil, true) end, "Increase number of columns", "Layout"},
    {"super+control+h", function() awful.tag.incncol(-1, nil, true) end, "Decrease number of columns", "Layout"},
    {"super+control+k", function() awful.client.incwfact(WIDTH_FACTOR) end, "Increase window width factor", "Layout"},
    {"super+control+j", function() awful.client.incwfact(-1 * WIDTH_FACTOR) end, "Decrease window width factor", "Layout"},
    -- Tag
    {"super+Tab", function() awful.tag.history.restore(); tag.emit_signal("property::tag_changed") end, "Toggle last two tags", "Tag"},
    awful.key {
        modifiers = { keys.super },
        keygroup = "numrow",
        description = "View tag",
        group = "Tag",
        on_press = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
                tag:emit_signal("property::tag_changed")
            end
        end,
    },
    -- Launcher
    {"super+Return", spawn(Vars.terminal), "Open terminal", "Launcher"},
    {"super+d", spawn(Vars.launcher), "Show rofi", "Launcher"},
    {"alt+shift+Tab", spawn(Vars.switcher), "App switcher", "Launcher"},
    {"super+`", function() if Vars.scratchpad then Vars.scratchpad:toggle() end end, "Terminal scratchpad", "Launcher"},
    -- System
    {"XF86MonBrightnessUp", spawn("light -A 10", "widgets::brightness"), "Increase brightness", "System"},
    {"XF86MonBrightnessDown", spawn("light -U 10", "widgets::brightness"), "Decrease brightness", "System"},
    {"XF86AudioMute", spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", "widgets::volume"), "System"},
    {"XF86AudioRaiseVolume", spawn("pamixer -i 5", "widgets::volume"), "System"},
    {"XF86AudioLowerVolume", spawn("pamixer -d 5", "widgets::volume"), "System"},
    {"super+shift+x", spawn("i3lock -c 24283b"), "System"},
    -- Desktop
    {"Print", function() scrot() end, "Take a screenshot", "Desktop"},
    {"shift+Print", function() scrot('-u') end, "Screenshot of focused client", "Desktop"},
    {"super+alt+j", function() awful.screen.focus_relative(1) end, "Focus next screen", "Desktop"},
    {"super+alt+k", function() awful.screen.focus_relative(-1) end, "Focus previous screen", "Desktop"},
    {"super+shift+d", function() Vars.do_not_disturb = not Vars.do_not_disturb; awesome.emit_signal("widgets::notification") end, "Toggle DND", "Desktop"},
    -- Client
    {"super+j", function() awful.client.focus.byidx(1) end, "Focus next client", "Client"},
    {"super+k", function() awful.client.focus.byidx(-1) end, "Focus previous client", "Client"},
    {"super+shift+j", function() awful.client.swap.byidx(1) end, "Swap with next client", "Client"},
    {"super+shift+k", function() awful.client.swap.byidx(-1) end, "Swap with previous client", "Client"},
    {"alt+Tab", function() awful.client.focus.history.previous() if client.focus then client.focus:raise() end end, "Switch focus", "Client"},
    {"super+u", awful.client.urgent.jumpto, "Jump to urgent client", "Client"},
    awful.key {
        modifiers = { keys.super, keys.shift },
        keygroup = "numrow",
        description = "Move focused client to tag",
        group = "Client",
        on_press = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers = { keys.super, keys.control },
        keygroup = "numrow",
        description = "Toggle focused client on a tag",
        group = "Client",
        on_press = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                    tag:emit_signal("property::tag_changed")
                end
            end
        end,
    },
})

-- Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function() Vars.main_menu:toggle() end),
})

-- Client bindings
client.connect_signal("request::default_keybindings", function()
awful.keyboard.append_client_keybindings(add_keybindings {
    {"super+shift+n", function(c) c:move_to_screen() end, "Move to screen", "Client"},
    {"super+o", function(c) c.ontop = not c.ontop end, "Toggle window ontop", "Client"},
    {"super+shift+q", function(c) c:kill() end, "Kill focused window", "Client"},
    {"alt+F4", function(c) c:kill() end, "Kill focused window", "Client"},
    {"super+s", function(c) c.sticky = not c.sticky; c:raise() end, "Toggle client pin", "Client"},
    {"super+m", function(c) c.minimized = true end, "Minimize focused client", "Client"},
    {"super+shift+f", function(c) c.fullscreen = not c.fullscreen; c:raise() end, "Toggle fullscreen", "Client"},
    {"super+shift+Return", function(c) c:swap(awful.client.getmaster()) end, "Move to master", "Client"},
    {"super+control+space", function(c)
        c.floating = not c.floating
        if c.terminal then c.manual_float = c.floating end
        if c.last_geometry then c:geometry(c.last_geometry) end
        if not beautiful.titlebars_enabled
        and beautiful.titlebars_on_floating
        and not c.manual_titlebar then
            if c.floating then
                awful.titlebar.show(c)
            else
                awful.titlebar.hide(c)
            end
        end
    end, "Toggle floating", "Client"},
    {"super+f", function(c)
        if not c.fullscreen then
            c.maximized = not c.maximized
        else
            c.fullscreen = not c.fullscreen
        end
        c:raise()
    end, "Toggle maximize", "Client"},
    {"super+t", function(c)
        if c.has_titlebars then
            c.manual_titlebar = true
            if c.titlebars_enabled then
                c.titlebars_enabled = false
                awful.titlebar.hide(c)
            else
                c.titlebars_enabled = true
                awful.titlebar.show(c)
            end
        end
    end, "Toggle titlebars for a client", "Client"},
})
end)

client.connect_signal("request::default_mousebindings", function()
awful.mouse.append_client_mousebindings({
    awful.button({}, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
        end),
    awful.button({keys.super}, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.move(c)
        end),
    awful.button({keys.super, keys.shift}, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.resize(c)
        end),
})
end)
