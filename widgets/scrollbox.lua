local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

return function(args)
    local append_widgets = args.append_widgets or false
    local layout = wibox.layout {
        last_y = 0,
        item_height = args.item_height or beautiful.menu_height or 50,
        height = args.height,
        forced_width = args.width,
        spacing = args.spacing or 0,
        layout = wibox.layout.manual,
    }

    local widget = wibox.widget {
        layout,
        bg = args.bg,
        fg = args.fg,
        forced_height = args.height,
        shape = function(cr, w, h) gears.shape.rectangle(cr, w, h) end,
        widget = wibox.container.background,
    }

    local scroll = {
        position = 0,
        steps = args.scroll_steps or 10,
    }

    widget.add_widget = function(self, widget)
        -- init point
        widget.forced_width = self.widget.forced_width
        widget.point = {
            x = 0,
            y = self.widget.last_y,
        }
        widget._original_y = widget.point.y
        widget.item_height = widget.forced_height or self.widget.item_height
        self.widget.last_y = widget.item_height + widget._original_y + self.widget.spacing

        -- Connect movement signal
        self.widget:connect_signal("widget::move", function(_, delta)
            if widget then
                widget.point.y = widget._original_y + delta
                self.widget:move_widget(widget, widget.point)
            end
        end)

        -- add to layout
        if append_widgets then
            self.widget:add(widget)
            self.widget:emit_signal("widget::move", -1 * scroll.position)
        else
            self.widget:insert(1, widget)
            self.widget:emit_signal("layout::reinit")
        end
    end

    widget.remove_widget = function(self, widget)
        local widgets = self.widget:get_children()
        for i,w in ipairs(widgets) do
            if w == widget then
                table.remove(widgets, i)
                break
            end
        end
        self.widget:set_children(widgets)
        self.widget:emit_signal("widget::redraw_needed")
        self.widget:emit_signal("layout::reinit")
        self.widget:emit_signal("widget::removed")
    end

    widget.remove_all_widgets = function(self)
        self.widget:set_children({})
        self.widget:emit_signal("widget::redraw_needed")
        self.widget:emit_signal("layout::reinit")
        self.widget:emit_signal("widget::removed")
    end

    widget.get_widget_by_id = function(self, id)
        for _,w in ipairs(self.widget:get_children()) do
            if w.id == id then
                return w
            end
        end
    end

    widget.reset_position = function(self)
        scroll.position = 0
        self.widget:emit_signal("widget::move", -1 * scroll.position)
    end

    layout:connect_signal("layout::reinit", function(l)
        l.last_y = 0
        for _,w in ipairs(l:get_children()) do
            w._original_y = l.last_y
            w.item_height = w.forced_height or l.item_height
            l.last_y = w.item_height + w._original_y + l.spacing
        end
        l:emit_signal("widget::redraw_needed")
        l:emit_signal("widget::updated")
        l:emit_signal("widget::move", -1 * scroll.position)
        if #l:get_children() == 0 then scroll.position = 0 end
    end)

    layout:connect_signal("button::press", function(l, _, _, button)
        if button == 4 then
            scroll.position = scroll.position - scroll.steps
            if scroll.position <= 0 then scroll.position = 0 end
        elseif button == 5 then
            if l.height and l.last_y - scroll.position >= l.height then
                scroll.position = scroll.position + scroll.steps
            elseif l.height == nil then
                scroll.position = scroll.position + scroll.steps
            end
        end
        l:emit_signal("widget::move", -1 * scroll.position)
    end)

    if args.widgets then
        local append_status = append_widgets
        append_widgets = true
        for _,w in ipairs(args.widgets) do
            widget:add_widget(w)
        end
        append_widgets = append_status
    end

    return widget
end
