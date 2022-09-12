local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local awestore = require("awestore")
local beautiful = require("beautiful")
local playerctl = require("bling.signal.playerctl").lib {
    player = { "spotify" },
}

local icon = {
    previous = "玲",
    next = "怜",
    play = "",
    pause = "",
}

return function(args)
    local widget_textbox = wibox.widget {
        font = beautiful.media_player_widget_font,
        widget = wibox.widget.textbox,
    }

    local artist_textbox = wibox.widget {
        font = beautiful.media_player_artist_font or 'Teko SemiBold 12',
        widget = wibox.widget.textbox,
    }

    local title_textbox = wibox.widget {
        font = beautiful.media_player_title_font or 'Teko Light 12',
        widget = wibox.widget.textbox,
    }

    local album_art = wibox.widget {
        widget = wibox.widget.imagebox,
    }

    local play_pause = wibox.widget {
        text = icon.pause,
        font = "Monospace 20",
        widget = wibox.widget.textbox,
        buttons = { awful.button({}, 1, function() playerctl:play_pause() end) },
    }

    local music_controls = wibox.widget {
        {
            text = icon.previous,
            font = "Monospace 20",
            widget = wibox.widget.textbox,
            buttons = { awful.button({}, 1, function() playerctl:previous() end) },
        },
        play_pause,
        {
            text = icon.next,
            font = "Monospace 20",
            widget = wibox.widget.textbox,
            buttons = { awful.button({}, 1, function() playerctl:next() end) },
        },
        spacing = 20,
        layout = wibox.layout.fixed.horizontal,
    }

    local music_controls_bar = wibox.widget {
        {
            {
                {
                    artist_textbox,
                    {
                        title_textbox,
                        max_size = 130,
                        step_function = wibox.container.scroll.step_functions
                           .waiting_nonlinear_back_and_forth,
                        speed = args.scroll_speed or 50,
                        fps = args.scroll_fps,
                        widget = wibox.container.scroll.horizontal,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                nil,
                {
                    music_controls,
                    margins = 5,
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal,
            },
            margins = 5,
            widget = wibox.container.margin
        },
        bg = "#000000df",
        forced_width = args.width or 250,
        widget = wibox.container.background,
    }


    local opacity_tween = awestore.tweened(0, {
        duration = 200,
        easing = awestore.easing.cubic_in_out,
    })

    opacity_tween:subscribe(function(v)
        music_controls_bar.opacity = v
    end)

    music_controls_bar:connect_signal("mouse::enter", function(_)
        opacity_tween:set(1)
    end)

    music_controls_bar:connect_signal("mouse::leave", function(_)
        opacity_tween:set(0)
    end)

    local popup = awful.popup {
        widget = {
            {
                album_art,
                {
                    music_controls_bar,
                    valign = 'bottom',
                    widget = wibox.container.place,
                },
                layout = wibox.layout.stack,
            },
            forced_width = args.width or 250,
            forced_height = args.height or 250,
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
        {
            {
                {
                    text = "",
                    widget = wibox.widget.textbox,
                },
                margins = 1,
                widget = wibox.container.margin
            },
            {
                widget_textbox,
                max_size = args.max_size or 150,
                step_function = wibox.container.scroll.step_functions
                   .waiting_nonlinear_back_and_forth,
                speed = args.scroll_speed or 50,
                fps = args.scroll_fps,
                widget = wibox.container.scroll.horizontal,
            },
            {
                text = string.rep(" ", args.spacing or 0),
                widget = wibox.widget.textbox,
            },
            spacing = 5,
            layout = wibox.layout.fixed.horizontal,
        },
        buttons = {
            awful.button({}, 1, function()
                popup.visible = not popup.visible
            end)
        },
        visible = false,
        fg = args.fg,
        shape = args.shape,
        widget = wibox.container.background,
    }

    -- Connect signals
    local title_string = ''
    playerctl:connect_signal("metadata", function(_, title, artist, album_path, _, new)
        title_string = artist .. ' - ' .. title
        artist_textbox:set_markup_silently(artist)
        title_textbox:set_markup_silently(title)
        if new or title_string == ' - ' then
            widget_textbox:set_markup_silently(title_string)
        end
        album_art:set_image(gears.surface.load_uncached(album_path))
    end)

    playerctl:connect_signal("playback_status", function(_, is_playing)
        widget.visible = true
        widget.opacity = is_playing and 1 or 0.3
        play_pause.text = is_playing and icon.pause or icon.play

        if not is_playing then
            widget_textbox.text = ''
        else
            widget_textbox:set_markup_silently(title_string)
        end
    end)

    playerctl:connect_signal("no_players", function()
        widget.visible = false
    end)

    if args.autohide == true then
        local hide_timer = gears.timer {
            single_shot = true,
            timeout = 3,
            callback = function()
                popup.visible = false
            end
        }
        popup:connect_signal("mouse::enter", function() if hide_timer.started then hide_timer:stop() end end)
        popup:connect_signal("mouse::leave", function() if not hide_timer.started then hide_timer:start() end end)
    end

    return widget
end
