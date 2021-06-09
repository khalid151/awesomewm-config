local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
-- TODO: nested menus

-- args:
--      items: table of menu items
--          text: text of menu entry
--          action: action to be performed when selected
--          font: font used for this item
--          height: height of this item
--          shape: shape of this item
--          spacing: space between text and icon
--          fg_normal: foreground when unselected
--          bg_normal: background when unselected
--          fg_focus: foreground when selected
--          bg_focus: background when selected
--          icon: icon to be display
--          icon_focus: icon used when selected
--          recolor_icon: to match icon color with fg when selected
--      font: font used for all items
--      height: height for all items
--      width: width of menu
--      fg_normal: foreground for all unselected items
--      bg_normal: background for all unselected items
--      fg_focus: foreground for all selected items
--      bg_focus: background for all selected items
--      spacing: spacing between icon and text for all items
--      items_spacing: spacing between menu items
--      shape: shape used for menu
--      items_shape: shape used for all items
--      bg: background for the popup menu
--      x: x position
--      y: y position
--      placement: placement rules of menu
--      autohide: hide menu when losing focus
return function(args)
    local index = 1 -- track selected item
    local popup -- the menu
    local keys -- keygrabber
    local widgets = {} -- hold menu items

    for _,item in ipairs(args.items) do
        local widget = wibox.widget {
            {
                {
                    text = item.text or item[1],
                    font = item.font or args.font or beautiful.font,
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            forced_height = item.height or args.height or beautiful.menu_height,
            forced_width = args.width or beautiful.menu_width,
            fg = item.fg_normal or args.fg_normal or beautiful.fg_normal,
            bg = item.bg_normal or args.bg_normal or beautiful.bg_normal,
            shape = item.shape or args.items_shape,
            spacing = item.spacing or args.spacing or 2,
            widget = wibox.container.background,
        }
        -- insert an imagebox if icon is present
        local icon
        if item.icon then
            icon = wibox.widget {
                image = item.icon,
                widget = wibox.widget.imagebox,
            }
            widget.widget:insert(1, wibox.widget {
                icon,
                margins = item.icon_margins or args.icon_margins or 0,
                widget = wibox.container.margin,
            })
        end
        -- connect action signal and hide the popup on key release
        if item.action or type(item[2]) == "function" then
            widget.action = item.action or item[2] -- useful for keyboard bindings
            widget:connect_signal("button::press", item.action or item[2])
        end
        widget:connect_signal("button::release", function()
            popup.visible = false
            keys:stop()
        end)
        -- Highlight
        widget.select = function(self)
            index = _
            self.fg = item.fg_focus or args.fg_focus or beautiful.fg_focus
            self.bg = item.bg_focus or args.bg_focus or beautiful.bg_focus
            if item.icon_focus then
                icon.image = item.icon_focus
            end
            if item.recolor_icon == true then
                icon.image = gears.color.recolor_image(item.icon_focus or item.icon, self.fg)
            end
        end
        widget.unselect = function(self)
            self.fg = item.fg_normal or args.fg_normal or beautiful.fg_normal
            self.bg = item.bg_normal or args.bg_normal or beautiful.bg_normal
            if item.icon then
                icon.image = item.icon
            end
            if item.recolor_icon == true then
                icon.image = gears.color.recolor_image(icon.image, self.fg)
            end
        end
        widget:connect_signal("mouse::enter", widget.select)
        widget:connect_signal("mouse::leave", widget.unselect)

        widgets[_] = widget
    end
    widgets['layout'] = wibox.layout.fixed.vertical
    widgets.spacing = args.items_spacing

    popup = awful.popup {
        widget = widgets,
        bg = args.bg or "transparent",
        shape = args.shape,
        visible = false,
        ontop = true,
        x = args.x,
        y = args.y,
        screen = args.screen,
    }

    -- To hide popup
    if args.autohide == true then
        local hide_timer = gears.timer {
            single_shot = true,
            timeout = 0.5,
            callback = function()
                popup.visible = false
                keys:stop()
            end
        }
        popup:connect_signal("mouse::enter", function() if hide_timer.started then hide_timer:stop() end end)
        popup:connect_signal("mouse::leave", function() if not hide_timer.started then hide_timer:start() end end)
    end
    -- unselect last item, just in case it was selected by keyboard
    popup:connect_signal("mouse::enter", function() if index ~= 0 then widgets[index]:unselect() end end)

    -- Grabbing keyboard
    local select_up = function()
        if index > 1 then
            index = index - 1
        end
        widgets[index]:select()
        widgets[index+1]:unselect()
    end
    local select_down = function()
        if index < #widgets then
            index = index + 1
        end
        widgets[index]:select()
        if index - 1 ~= 0 then widgets[index-1]:unselect() end
    end

    keys = awful.keygrabber {
        keybindings = {
            awful.key { modifiers = {}, key = 'k', on_press = select_up },
            awful.key { modifiers = {}, key = 'j', on_press = select_down },
            awful.key { modifiers = {}, key = 'Up', on_press = select_up },
            awful.key { modifiers = {}, key = 'Down', on_press = select_down },
        },
        stop_key = {'Escape', 'Return'},
        stop_event = 'release',
        stop_callback = function(_, stop_key)
            if stop_key == "Return" then
                if index ~= 0 then
                    local action = widgets[index].action
                    if action then action() end
                end
            end
            popup.visible = false
        end,
    }

    -- Visibility functions
    popup.toggle = function(self)
        if index ~= 0 then widgets[index]:unselect() end
        index = 0 -- reset index

        -- Set placement here to fix jumping menu when changing image
        if self.visible then
            self.visible = false
            keys:stop()
        else
            if args.placement then args.placement(self) end
            self.visible = true
            keys:start()
        end
    end
    popup.show = function(self)
        if args.placement then args.placement(self) end
        self.visible = true
        keys:start()

        if index ~= 0 then widgets[index]:unselect() end
        index = 0 -- reset index
    end
    popup.hide = function(self)
        self.visible = false
        keys:stop()
    end

    return popup
end
