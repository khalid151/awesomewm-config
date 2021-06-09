-- First, determine if it's running on desktop or laptop, to load the theme variant
local f = assert(io.open(os.getenv("HOME") .. "/.config/awesome/environment"))
local environment = f:read("*all"):gsub("\n", "")
f:close()

-- Check for luarocks
pcall(require, "luarocks.loader")

-- Load theme. TODO: better theme loader?
local theme = "default"
local beautiful = require("beautiful")
beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), theme))

-- Libs
local awful = require("awful")
local bling = require("bling")
local helper = require("utils.helper")
local menu = require("widgets.menu")

-- VARIABLES ------------------------------------------------------------------
Vars = {
    do_not_disturb = false, -- Notifications display state
    editor = os.getenv("EDITOR") or "vi",
    environment = environment, -- On desktop or laptop
    launcher = os.getenv("HOME") .. "/.config/rofi/launchers/launcher.sh",
    switcher = os.getenv("HOME") .. "/.config/rofi/launchers/switcher.sh",
    terminal = "alacritty",
    test_menu = menu {
        items = {
            {
                text = " one",
                action = function() print("one") end,
            },
            {" two", function() print("two") end},
        },
        font = "Iosevka 20",
        --items_spacing = 5,
        shape = beautiful.rounded_rect,
        fg_normal = beautiful.bg_normal,
        bg_normal = beautiful.fg_normal,
        height = 50,
        width = 200,
        placement = awful.placement.next_to_mouse,
    }
}

Vars.main_menu = awful.menu({
        {"Terminal", Vars.terminal},
        {
            "Awesome", {
                {"Restart", awesome.restart},
                {"Exit", function() awesome.quit() end},
            },
            beautiful.awesome_icon,
        }
})

-- CONFIG ---------------------------------------------------------------------
require("awful.autofocus")
require("keymaps")
require("rules")
require("notifications")

awful.titlebar.enable_tooltip = false

-- SET DESKTOP ----------------------------------------------------------------
awful.screen.connect_for_each_screen(beautiful.set_wallpaper)

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.max,
    })
end)

screen.connect_signal("request::desktop_decoration", function(s)
    local l = awful.layout.suit
    helper.add_tags(s, {
        {
            name = "home",
            properties = {
                icon = beautiful.tag_icon.home,
                layout = l.floating,
                selected = true,
            }
        },
        {
            name = "internet",
            properties = {
                icon = beautiful.tag_icon.internet,
                layout = l.max,
                useless_gap = 0,
            }
        },
        {
            name = "code",
            properties = {
                icon = beautiful.tag_icon.code,
                layout = l.tile
            }
        },
        {
            name = "office",
            properties = {
                icon = beautiful.tag_icon.office,
            }
        },
        {
            name = "media",
            properties = {
                icon = beautiful.tag_icon.media,
                layout = l.max
            }
        },
        {
            name = "art",
            properties = {
                icon = beautiful.tag_icon.art,
                layout = l.tile,
                layouts = {
                    l.tile,
                    l.max,
                },
                master_width_factor = 0.8,
            }
        },
        {
            name = "games",
            properties = {
                icon = beautiful.tag_icon.games,
                layout = l.max,
            }
        },
        {
            name = "misc",
        },
        {
            name = "chat",
            properties = {
                icon = beautiful.tag_icon.chat,
                layout = l.tile
            }
        },
    })
end)

require(beautiful.bar)

-- SIGNALS --------------------------------------------------------------------
-- When a client asks for focus (e.g. using rofi as app switcher), switch to that client
awful.permissions.add_activate_filter(function(c)
    c:jump_to()
    tag.emit_signal("property::tag_changed")
end, "ewmh")

client.connect_signal("focus", function (c)
    client.emit_signal("check_focused")
    c.border_color = beautiful.border_focus
    c.border_width = beautiful.border_width

    if c.class == "Termite" then
        local icon = beautiful.icons['24x24']['terminal']
        if icon then
            c.icon = helper.icon_surface(icon)
        end
    end

    local instance = c.instance or ''
    local icon = beautiful.icons['24x24'][instance:lower()]
    if icon then
        c.icon = helper.icon_surface(icon)
    end
end)

client.connect_signal("unfocus", function (c)
    if c then
        if not helper.delayed_focus_signal.started then
            helper.delayed_focus_signal:start()
        end
        c.border_color = beautiful.border_normal
        c.border_width = beautiful.border_width
    end
end)

client.connect_signal("request::manage", function (c)
    local layout = awful.screen.focused().selected_tag.layout.name
    if not beautiful.titlebars_enabled
    and beautiful.titlebars_on_floating
    and layout == "floating"
    and c.has_titlebars
    and not c.manual_titlebar then
        awful.titlebar.show(c)
    end
end)

local titlebar = require("titlebar")

client.connect_signal("request::titlebars",
    function(c)
        c.has_titlebars = true
        c.titlebars_enabled = true
        awful.titlebar(c, beautiful.titlebar_config):setup(titlebar.generate(c))
        if not beautiful.titlebars_enabled and c.type ~= "dialog" then
            awful.titlebar.hide(c)
            c.titlebars_enabled = false
        end
end)

client.connect_signal("property::geometry", function(c)
    local tag = awful.screen.focused().selected_tag
    if tag then
        if tag.layout.name == "floating" or c.floating then
            c.last_geometry = c:geometry()
        end
    end
end)

-- Fix problem where borders disappear when window is maximized
client.connect_signal("property::maximized", function(c)
    c.border_width = beautiful.border_width
end)

local update_clients_on_tag = function(tag)
    if tag.layout.name == "floating" then
        for _,c in ipairs(awful.screen.focused().clients) do
            c:geometry(c.last_geometry)
            if beautiful.titlebars_on_floating and not c.manual_titlebar and c.has_titlebars then
                awful.titlebar.show(c)
            end
        end
    elseif not beautiful.titlebars_enabled and beautiful.titlebars_on_floating then
        for _,c in ipairs(awful.screen.focused().clients) do
            if not c.manual_titlebar and not c.floating then
                awful.titlebar.hide(c)
            end
        end
    end
end

tag.connect_signal("property::layout", function()
    local tag = awful.screen.focused().selected_tag

    -- Reset manual titlebar switching status
    if beautiful.titlebars_on_floating then
        for _,c in ipairs(awful.screen.focused().clients) do
            c.manual_titlebar = false
        end
    end

    update_clients_on_tag(tag)
end)

tag.connect_signal("property::tag_changed", function()
    local tag = awful.screen.focused().selected_tag

    -- Check if it's a terminal so you make it floating on internet tag
    for _,c in ipairs(awful.screen.focused().clients) do
        if c.terminal and c.floating_on_tag then
            if tag.name == "internet" then
                c.floating = true
            else
                -- Check if floating was changed manually
                c.floating = true and c.manual_float
            end
        end
    end

    update_clients_on_tag(tag)
end)

-- STARTUP --------------------------------------------------------------------
awful.spawn.once("xmodmap " .. os.getenv("HOME") .. "/.xmodmap")
awful.spawn.single_instance("picom -b")
awful.spawn.single_instance("wactions")

-- OTHERS ---------------------------------------------------------------------
Vars.scratchpad = bling.module.scratchpad:new {
    command = "alacritty --class ,Scratchpad --working-directory ~ -e tmux",
    rule = { class = "Scratchpad" },
    sticky = true,
    floating = true,
    geometry = {x=0, y=beautiful.bar_height+5, height=320, width=600},
    reapply = true,
    dont_focus_before_close  = false,
}
