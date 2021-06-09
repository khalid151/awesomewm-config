local beautiful = require("beautiful")
local gears = require("gears")
local helper = require("utils.helper")

local xresources = beautiful.xresources
local dpi = xresources.apply_dpi

local theme = {}
theme.dpi = dpi

local icons = {
    devices = beautiful.theme_path .. "/devices/",
    misc = beautiful.theme_path .. "/misc/",
    titlebar = beautiful.theme_path .. "/titlebar/",
}

-- Colors ---------------------------------------------------------------------
local colors = require('colorschemes.x_dotshare')
theme.colors = colors

theme.fg_normal = colors.foreground
theme.fg_focus = colors.color3
theme.bg_normal = colors.color8
theme.bg_focus = colors.color0
theme.bg_urgent = colors.color1
theme.bg_systray = colors.background
-- Bar colors
theme.bar_bg = colors.color0
theme.bar_fg = colors.foreground
theme.task_switcher_bg = colors.foreground
theme.task_switcher_fg = colors.color0
theme.task_switcher_indicator = colors.color1
theme.taglist_active = colors.color3
theme.taglist_inactive = colors.color6
-- Hotkeys colors
theme.hotkeys_bg = colors.foreground .. "d0"
theme.hotkeys_fg = colors.background .. "f0"
-- Titlebar colors
theme.titlebar_fg_normal = colors.foreground .. "30"
theme.titlebar_bg = colors.background
theme.titlebar_fg_focus = colors.foreground
theme.titlebar_bg_focus = colors.color0
-- Border colors
theme.border_normal = colors.background
theme.border_focus  = colors.color3
-- Notification colors
theme.notification_bg_normal = colors.foreground .. "fe"
theme.notification_fg_normal = colors.background
theme.notification_bg_critical = "#ff3838"
theme.notification_fg_critical = "#ffffff"
theme.notification_center_bg = colors.background .. "80"

-- Settings -------------------------------------------------------------------
theme.icon_theme = 'Papirus'
theme.icons = helper.cache_icons(theme.icon_theme, '24x24;48x48')
theme.font_name = "Iosevka "
theme.font = theme.font_name .. dpi(8)
theme.useless_gap = 0
theme.widget_icon_margin = dpi(5)
theme.systray_size = dpi(24)

theme.set_wallpaper = function()
    local awful = require("awful")
    awful.spawn(os.getenv("HOME") .. "/.fehbg")
end

-- Shapes ---------------------------------------------------------------------
theme.rounded_rect = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 5)
end

-- Bar config -----------------------------------------------------------------
theme.bar = "bar.default"
theme.bar_height = dpi(35)
theme.bar_position = "top"
theme.bar_ontop = false
theme.bar_min_opacity = 0
theme.bar_max_opacity = 255
theme.bar_fade_duration = 300
theme.toggle_bar_opacity = true

theme.task_switcher_font = "Teko " .. dpi(10)

theme.clock_font = theme.font_name .. dpi(9)

-- Hotkeys config -------------------------------------------------------------
theme.hotkeys_shape = theme.rounded_rect
theme.hotkeys_border_width = 0

-- Titlebars and borders ------------------------------------------------------
theme.titlebars_enabled = false
theme.titlebars_on_floating = true
theme.titlebar_autohide_controls = false
theme.titlebar_size = dpi(24)
theme.titlebar_font = theme.font
theme.titlebar_title_align = "center"
theme.titlebar_position = "top"
theme.titlebar_config = {
    position = theme.titlebar_position,
    size = theme.titlebar_size,
    font = theme.titlebar_font
}

theme.titlebar_icon_margins = dpi(4)
theme.titlebar_icon_spacing = dpi(2)

-- close icons
theme.titlebar_close_button_focus  = icons.titlebar .. 'close_normal.png'
theme.titlebar_close_button_focus_hover  = icons.titlebar .. 'close_hover.png'
theme.titlebar_close_button_focus_press  = icons.titlebar .. 'close_normal.png'
theme.titlebar_close_button_normal = icons.titlebar .. 'close_normal_inactive.png'
theme.titlebar_close_button_normal_hover = icons.titlebar .. 'close_normal.png'
theme.titlebar_close_button_normal_press = icons.titlebar .. 'close_normal_inactive.png'
-- minimize icons
theme.titlebar_minimize_button_focus = icons.titlebar .. 'min_normal.png'
theme.titlebar_minimize_button_focus_hover = icons.titlebar .. 'min_hover.png'
theme.titlebar_minimize_button_focus_press = icons.titlebar .. 'min_normal.png'
theme.titlebar_minimize_button_normal = icons.titlebar .. 'min_normal.png'
theme.titlebar_minimize_button_normal_hover = icons.titlebar .. 'min_hover.png'
-- maximize icons
theme.titlebar_maximized_button_focus_active = icons.titlebar .. "unmax_normal.png"
theme.titlebar_maximized_button_focus_active_hover = icons.titlebar .. "unmax_hover.png"
theme.titlebar_maximized_button_focus_active_press = icons.titlebar .. "unmax_normal.png"
theme.titlebar_maximized_button_focus_inactive = icons.titlebar .. "max_normal.png"
theme.titlebar_maximized_button_focus_inactive_hover = icons.titlebar .. "max_hover.png"
theme.titlebar_maximized_button_focus_inactive_press = icons.titlebar .. "max_normal.png"
theme.titlebar_maximized_button_normal_active = icons.titlebar .. "unmax_normal.png"
theme.titlebar_maximized_button_normal_active_hover = icons.titlebar .. "unmax_hover.png"
theme.titlebar_maximized_button_normal_inactive = icons.titlebar .. "max_normal.png"
theme.titlebar_maximized_button_normal_inactive_hover = icons.titlebar .. "max_hover.png"
-- TODO: ontop icons
-- TODO: floating
-- sticky icons
theme.titlebar_sticky_button_normal_inactive = icons.titlebar .. "empty.png"
theme.titlebar_sticky_button_focus_inactive  = icons.titlebar .. "pin_inactive.png"
theme.titlebar_sticky_button_focus_inactive_hover  = icons.titlebar .. "pin_inactive_hover.png"
theme.titlebar_sticky_button_normal_active = icons.titlebar .. "pin.png"
theme.titlebar_sticky_button_focus_active  = icons.titlebar .. "pin.png"
theme.titlebar_sticky_button_focus_active_hover  = icons.titlebar .. "pin_hover.png"

theme.border_width  = dpi(1)

-- Notifications --------------------------------------------------------------
theme.notification_padding = dpi(10)
theme.notification_width = dpi(300)
theme.notification_height = dpi(100)
theme.notification_max_width = dpi(300)
theme.notification_icon_size = dpi(100)
theme.notification_border_width = 0
theme.notification_spacing = dpi(5)
theme.notification_font = theme.font_name .. ' 8'
theme.notification_font_title = 'Teko ' .. dpi(12)
theme.notification_position = "top_middle"

gears.timer {
    timeout = 2,
    single_shot = true,
    autostart = true,
    callback = function()
        theme.notification_default_icon = theme.icons['48x48']['dialog-information']
        theme.notification_error_icon = theme.icons['48x48']['computer-fail']
    end
}

-- Menus ----------------------------------------------------------------------
theme.menu_border_width = 0
theme.menu_height = dpi(20)
theme.menu_width  = dpi(100)

-- Icons ----------------------------------------------------------------------
theme.tag_icon = {
    home = "/usr/share/icons/Papirus/24x24/actions/go-home.svg",
    internet = "/usr/share/icons/Papirus/24x24/actions/globe.svg",
    code = "/usr/share/icons/Papirus/24x24/actions/dialog-xml-editor.svg",
    office = "/usr/share/icons/Papirus/24x24/actions/fileopen.svg",
    media = "/usr/share/icons/Papirus/24x24/actions/view-media-track.svg",
    art = "/usr/share/icons/Papirus/24x24/actions/draw-path.svg",
    games = "/usr/share/icons/Papirus/24x24/actions/draw-cuboid.svg",
    chat = "/usr/share/icons/Papirus/24x24/actions/dialog-messages.svg",
    default = "/usr/share/icons/Papirus/24x24/actions/cm_options.svg",
}

theme.battery_icons = {
    charging = {
        icons.devices .. 'batt_25_ch.png',
        icons.devices .. 'batt_50_ch.png',
        icons.devices .. 'batt_75_ch.png',
        icons.devices .. 'batt_fu_ch.png',
    },
    discharging = {
        icons.devices .. 'batt_25_di.png',
        icons.devices .. 'batt_50_di.png',
        icons.devices .. 'batt_75_di.png',
        icons.devices .. 'batt_fu_di.png',
    }
}
theme.volume_icons = {
    level = {
        icons.devices .. 'sound_0.png',
        icons.devices .. 'sound_1.png',
        icons.devices .. 'sound_2.png',
        icons.devices .. 'sound_3.png',
    },
    muted = icons.devices .. 'sound_m.png'
}
theme.brightness_icons = {
    icons.devices .. 'brightness_00.png',
    icons.devices .. 'brightness_25.png',
    icons.devices .. 'brightness_50.png',
    icons.devices .. 'brightness_75.png',
    icons.devices .. 'brightness_fu.png',
}

theme.arrow_icon_left = icons.misc .. 'arrow_left.png'
theme.arrow_icon_right = icons.misc .. 'arrow_right.png'
theme.distro_icon = icons.misc .. 'arch.png'

return theme
