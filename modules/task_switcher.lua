local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local separator = require("widgets.separator")
local wibox = require("wibox")
local space = wibox.widget.textbox(" ")

-- args:
--      action = action to perform when clicking on tag icon
--      default_tag_icon = icon to use when tag has no specified icon
--      bg = background color
--      fg = text color
--      icon_color = color of icon
--      indicator_color = task switcher indicator color
--      separator_color = color to use for separator
--      font = font to be used
--      screen = tags and client on this screen
--      shape = shape for the background widget
return function(args)
    local focused_task = awful.widget.tasklist {
        screen = args.screen,
        filter = awful.widget.tasklist.filter.focused,
        widget_template = {
            {
                {
                    {
                        id     = 'clienticon',
                        widget = awful.widget.clienticon,
                    },
                    {
                        {
                            {
                                id = "title_role",
                                font = args.font,
                                valign = 'center',
                                widget = wibox.widget.textbox
                            },
                            fg = args.fg,
                            widget = wibox.container.background
                        },
                        top = 1,
                        widget = wibox.container.margin
                    },
                    spacing = 2,
                    layout = wibox.layout.fixed.horizontal
                },
                margins = (beautiful.widget_icon_margin or 2) - 2,
                widget = wibox.container.margin
            },
            create_callback = function(self, c, index, clientlist)
                self:get_children_by_id('clienticon')[1].client = c
                local str = c.class or "Unknown"
                self:get_children_by_id('title_role')[1].text = " " .. str:gsub("^%l", string.upper)
            end,
            update_callback = function(self, c, index, clientlist)
                local str = c.class or "Unknown"
                self:get_children_by_id('title_role')[1].text = " " .. str:gsub("^%l", string.upper)
            end,
            layout = wibox.layout.align.vertical,
        }
    }

    -- TODO: group tasks by class
    local tasklist = awful.widget.tasklist {
        screen = args.screen,
        filter = awful.widget.tasklist.filter.alltags,
        buttons = {
            awful.button({}, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    if awful.screen.focused().selected_tag ~= c.first_tag then
                        c.first_tag:view_only()
                        tag.emit_signal("property::tag_changed")
                    end
                    c:emit_signal("request::activate", "tasklist", {raise = true})
                end
            end)
        },
        layout = {
            spacing = 0,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                id = 'icon_container',
                {
                    {
                        id = 'indicator_highlight',
                        space,
                        bg = "linear:0,0:0,25:0,".. args.indicator_color .. ":1,transparent",
                        visible = false,
                        opacity = 0.2,
                        widget = wibox.container.background
                    },
                    {
                        {
                            id     = 'clienticon',
                            widget = awful.widget.clienticon,
                        },
                        margins = (beautiful.widget_icon_margin or 2) - 2,
                        widget = wibox.container.margin
                    },
                    {
                        id = 'indicator',
                        {
                            space,
                            bg = args.indicator_color,
                            forced_height = 25,
                            forced_width = 20,
                            shape = function(cr, w, h) gears.shape.rectangle(cr, 25, 2) end,
                            widget = wibox.container.background
                        },
                        valign = 'top',
                        widget = wibox.container.place
                    },
                    layout = wibox.layout.stack
                },
                bg = "transparent",
                widget = wibox.container.background
            },
            create_callback = function(self, c, index, clientlist)
                local icon = self:get_children_by_id('clienticon')[1]
                icon.client = c
                icon.opacity = icon.client.minimized and 0.4 or 1
                self:get_children_by_id('indicator')[1].visible = c == client.focus
                self:get_children_by_id('indicator_highlight')[1].visible = c == client.focus
            end,
            update_callback = function(self, c, index, clientlist)
                self:get_children_by_id('indicator')[1].visible = c == client.focus
                self:get_children_by_id('indicator_highlight')[1].visible = c == client.focus
                local icon = self:get_children_by_id('clienticon')[1]
                icon.visible = false
                icon.opacity = icon.client.minimized and 0.4 or 1
                icon.visible = true
            end,
            layout = wibox.layout.align.vertical,
        }
    }
    tasklist.visible = false

    local tag_task_separator = separator {
        color = args.separator_color or args.fg,
        thickness = 1,
        visible = false,
    }

    local tag_icon_launcher = wibox.widget {
        buttons = args.buttons,
        widget = wibox.widget.imagebox,
    }

    local widget = wibox.widget {
        {
            tag_icon_launcher,
            tag_task_separator,
            focused_task,
            tasklist,
            spacing = 0,
            layout = wibox.layout.fixed.horizontal
        },
        bg = args.bg,
        shape = args.shape,
        widget = wibox.container.background,
    }

    tag.connect_signal("property::tag_changed", function()
        -- When the current tag is changed, this function is triggered
        local tag = args.screen.selected_tag
        if tag then
            local icon = tag.icon or args.default_tag_icon
            if args.icon_color then
                tag_icon_launcher.image = gears.color.recolor_image(icon, args.icon_color)
            else
                tag_icon_launcher.image = icon
            end
        end
    end)

    -- Check if mouse is hovering over the tasklist, if not, hide it
    local double_check = gears.timer { timeout = 1 }
    double_check:connect_signal("timeout", function()
        local hovering = false
        local widgets = mouse.current_widgets
        if widgets then
            for _, widget in ipairs(widgets) do
                if widget == tasklist then
                    hovering = true
                    break
                end
            end
        end
        if not hovering then
            tasklist.visible = false
            focused_task.visible = true
            client.emit_signal("check_focused")
            double_check:stop()
        end
    end)

    local switch_timer = gears.timer {
        timeout = 0.3,
        single_shot = true,
        callback = function()
            tasklist.visible = not tasklist.visible
            focused_task.visible = not tasklist.visible
            client.emit_signal("check_focused")
        end,
    }

    local timers_starter = function(start)
        if start then
            if not switch_timer.started then switch_timer:start() end
        else
            if switch_timer.started then switch_timer:stop() end
        end
    end

    -- Start or stop timer
    focused_task:connect_signal("mouse::enter", function() timers_starter(true) end)
    focused_task:connect_signal("mouse::leave", function() timers_starter(false) end)
    tasklist:connect_signal("mouse::leave", function() timers_starter(true) end)
    tasklist:connect_signal("mouse::enter", function() timers_starter(false) end)
    tag_icon_launcher:connect_signal("mouse::enter", function()
        if not client.focus then
            timers_starter(true)
        end
    end)

    client.connect_signal("check_focused", function()
        tag_task_separator.visible = client.focus ~= nil and (not client.focus.skip_taskbar) or tasklist.visible
        widget.widget.spacing = tag_task_separator.visible and 2 or 0
    end)

    -- Emit this signal to set tag icons
    tag.emit_signal("property::tag_changed")
    tag_task_separator.visible = client.focus ~= nil

    return widget
end
