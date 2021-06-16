local awestore = require("awestore")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modules = require("modules")
local widgets = require("widgets")

-- Constants
local ANIM_DURATION = 500 -- when switching between taglist and textclock
local ANIM_TIMEOUT = 2 -- how long it takes to switch display textclock

-- TODO: create a layoutbox widget + create their icons
screen.connect_signal("request::desktop_decoration", function(s)
    -- Widgets
    local battery
    local brightness
    local textclock = widgets.textclock{format = "%a %b %d, %I:%M %p", font = beautiful.clock_font}
    local volume = widgets.volume {
        icons = beautiful.volume_icons,
        buttons = {
            awful.button({}, 3, nil, function() Vars.pa_volume:toggle() end),
        }
    }
    local launcher_menu = widgets.menu {
        items = Vars.main_menu_items,
        icon_margins = 5,
        font = beautiful.task_switcher_font,
        shape = beautiful.rounded_rect,
        x = 5,
        y = beautiful.bar_height,
        fg_normal = beautiful.task_switcher_fg,
        bg_normal = beautiful.task_switcher_bg,
        fg_focus = beautiful.task_switcher_bg,
        bg_focus = beautiful.colors.color8,
        height = 30,
        width = 120,
        autohide = true,
        screen = s,
    }

    if Vars.environment == "laptop" then
        battery = widgets.battery {
            icons = beautiful.battery_icons,
            spacing = 5,
            show_text = true,
        }
        brightness = widgets.brightness { icons = beautiful.brightness_icons }
    end

    local taglist = widgets.taglist {
        screen = s,
        active = beautiful.taglist_active,
        inactive = beautiful.taglist_inactive,
    }
    taglist.opacity = 0

    -- Create a table of widgets here, to ease wrapping it inside containers
    local rhs_bar_widgets = {
        volume,
        brightness,
        battery,
        widgets.space,
        spacing = 2,
        layout = wibox.layout.fixed.horizontal,
    }

    if screen.primary == s then
        table.insert(rhs_bar_widgets, 1, widgets.systray {
            base_size = beautiful.systray_size,
            show_icon = beautiful.arrow_icon_left,
            hide_icon = beautiful.arrow_icon_right,
            toggle_bg = true,
            bg = beautiful.bar_bg,
            shape = beautiful.rounded_rect,
        })
        table.insert(rhs_bar_widgets, 2, modules.notification_center {
            screen = s,
            shape = beautiful.rounded_rect,
            placement = function(d)
                return awful.placement.top_right(d, {
                    offset = {
                        x = -5,
                        y = beautiful.bar_height + 5,
                    }
                })
            end,
        })
    end

    s.bar = awful.wibar {
        screen = s,
        bg = string.format("%s%x", beautiful.bar_bg, beautiful.bar_min_opacity),
        ontop = beautiful.bar_ontop,
        position = beautiful.bar_position,
        height = beautiful.bar_height,
    }

    s.bar:setup {
        {
            modules.task_switcher {
                action = function() launcher_menu:toggle() end,
                font = beautiful.task_switcher_font,
                bg = beautiful.task_switcher_bg,
                fg = beautiful.task_switcher_fg,
                indicator_color = beautiful.task_switcher_indicator,
                screen = s,
                default_tag_icon = beautiful.tag_icon.default,
                shape = beautiful.rounded_rect,
            },
            margins = beautiful.widget_icon_margin + 1,
            widget = wibox.container.margin
        },
        {
            textclock,
            taglist,
            layout = wibox.layout.stack
        },
        {
            {
                {
                    {
                        rhs_bar_widgets,
                        margins = beautiful.widget_icon_margin,
                        widget = wibox.container.margin
                    },
                    bg = beautiful.bar_bg,
                    shape = beautiful.rounded_rect,
                    widget = wibox.container.background,
                },
                margins = 3,
                widget = wibox.container.margin
            },
            spacing = 5,
            layout = wibox.layout.fixed.horizontal,

        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    }

    -- Switch between textclock and taglist display
    local opacity_tween = awestore.tweened(0, {
        duration = ANIM_DURATION,
        easing = awestore.easing.cubic_in_out,
    })
    local fading_timer = gears.timer {
        timeout = 2,
        single_shot = true,
        callback = function() opacity_tween:set(0) end,
    }
    opacity_tween:subscribe(function(v)
        -- Animate opacity here
        textclock.visible, taglist.visible = false, false
        textclock.opacity, taglist.opacity = math.abs(1 - v), v
        textclock.visible, taglist.visible = true, true
    end)
    tag.connect_signal("property::tag_changed", function(t)
        if t then
            if t.screen == s then
                opacity_tween:set(1)
                fading_timer:again()
            end
        end
    end)
end)

if beautiful.toggle_bar_opacity then
    require("utils.bar_fade")
end
