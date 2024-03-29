local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local helper = require("utils.helper")
local ruled = require("ruled")

local focus_button = awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
end)

ruled.client.connect_signal("request::rules", function()
    -- For all clients
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            border_color = beautiful.border_normal,
            border_width = beautiful.border_width,
            focus = awful.client.focus.filter,
            honor_padding = true,
            honor_workarea = true,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen+awful.placement.centered,
            raise = true,
            screen = awful.screen.preferred,
            size_hints_honor = false,
            titlebars_enabled = function(c) return not c.requests_no_titlebar end,
            callback = awful.client.setslave,
        }
    }
    ruled.client.append_rule {
        rule = {},
        except = { class = "Alacritty" },
        properties = {
            callback = function(c)
                awful.client.setslave(c)
                -- Set icons
                if beautiful.icons then
                    local instance = c.instance or ''
                    local icon = beautiful.icons['24x24'][instance:lower()]
                    if icon then
                        c.icon = helper.icon_surface(icon)
                    end
                end
            end
        }
    }
    ruled.client.append_rule {
        rule = { instance = "Scratchpad" },
        properties = {
            buttons = { focus_button },
            skip_taskbar = true,
            ontop = true,
            titlebars_enabled = false,
            callback = function(c)
                -- Center in screen
                local g = Vars.scratchpad.geometry
                local w = c.screen.geometry.width
                g.x = w/2 - g.width/2
            end,
        }
    }
    ruled.client.append_rule {
        rule = {class = "Xephyr"},
        properties = {
            icon = function() return helper.icon_surface(beautiful.icons['24x24']['computer-laptop']) end
        }
    }
    ruled.client.append_rule {
        rule = {class = "copyq", type = "normal"},
        properties = {
            floating = true,
            skip_taskbar = true,
            sticky = true,
            titlebars_enabled = false,
            width = 400,
            height = 200,
            placement = awful.placement.centered + awful.placement.top,
        }
    }
    -- For titlebars
    ruled.client.append_rule {
        rule_any = {type = "dialog" },
        properties = {
            titlebars_enabled = true,
        }
    }
    ruled.client.append_rule {
        rule_any = {
            class = { "firefox", "Chromium-browser-chromium" },
            instance = { "brave-browser" },
        },
        except = { type = "dialog" },
        properties = {
            tag = "internet",
            screen = 1,
            titlebars_enabled = false,
        }
    }
    ruled.client.append_rule {
        rule_any = {
            name = { "Picture-in-Picture", "Picture in picture" },
        },
        properties = {
            sticky = true,
            ontop = true,
            floating = true,
        }
    }
    ruled.client.append_rule {
        id = "chat",
        rule_any = {
            type = "normal",
            class = {
                "discord",
                "TelegramDesktop",
                "Thunderbird",
                "Zulip",
            }
        },
        properties = { screen = 1, tag = "chat" }
    }
    ruled.client.append_rule {
        id = "drawing",
        rule_any = {
            type = "normal",
            class = {
                "Aseprite",
                "Blender",
                "Gimp",
                "Inkscape",
                "krita",
            },
        },
        except = { type = "dialog" },
        properties = {
            tag = "art",
            callback = function(c)
                if beautiful.wacom_focus then
                    local remap = function()
                        if c.first_tag.name == "art" then
                            helper.wacom_focus.client(c)
                        end
                    end
                    c:connect_signal("property::geometry", remap)
                    c:connect_signal("focus", remap)
                    c:connect_signal("unfocus", function()
                        c.screen.needs_wacom_focus = true
                    end)
                end
            end,
        }
    }
    ruled.client.append_rule {
        rule = {class = "Xfdesktop", type = "desktop"},
        properties = {
            sticky = true,
            focusable = false,
            border_width = 0,
            fullscreen = true,
            titlebars_enabled = false
        }
    }
    ruled.client.append_rule {
        rule_any = { class = {"steam", "Steam"}},
        properties = {
            tag = "games",
            titlebars_enabled = false,
        },
    }
    --ruled.client.append_rule {
        --id = 'games',
        --rule_any = { class = {
            --"steam_app",
            --"Chowdren",
            --}
        --},
        --properties = {
            --tag = "games",
            --callback = function(c)
                ---- Prevent games from minimizing on tag change
                --c:connect_signal("property::minimized", function(_c)
                    --if _c.minimized then
                        --_c.minimized = false
                        --_c.below = true
                    --end
                --end)
            --end
        --}
    --}
    ruled.client.append_rule {
        id = 'android-studio',
        rule = {
            class = "jetbrains-studio",
            name="^win[0-9]+$",
        },
        properties = {
            placement = awful.placement.no_offscreen,
        }
    }
    ruled.client.append_rule {
        rule = {
            name = "Android Emulator.*",
        },
        properties = {
            border_width = 0,
        },
    }
    ruled.client.append_rule {
        id = 'volume',
        rule = { class = 'Pavucontrol' },
        properties = {
            floating = true,
            skip_taskbar = true,
            sticky = true,
            titlebars_enabled = false,
            height = 400,
            width = 300,
            callback = function(c)
                local place = function()
                    c.height = 400
                    c.width = 500
                    awful.placement.top_right(c, {
                        offset = {
                            x = -5,
                            y = beautiful.bar_height + 5,
                        }
                    })
                end
                gears.timer {
                    autostart = true,
                    timeout = 0.05,
                    single_shot = true,
                    callback = place,
                }
                c:connect_signal("focus", place)
            end,
        }
    }
    ruled.client.append_rule {
        id = 'pico8',
        rule = { class = "pico8" },
        properties = {
            width = 512,
            height = 512,
        }
    }
    ruled.client.append_rule {
        rule = { class = "realvnc-vncserverui-service" },
        properties = {
            minimized = true,
        },
    }
end)
