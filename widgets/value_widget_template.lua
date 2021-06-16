-- Has common functions to battery, brightness, etc
local awful = require("awful")
local wibox = require("wibox")

-- args:
--      name = name of template\widget (used for signals)
--      font = text font
--      icons = list of icons to use
--      resize = resize icons
--      show_text = visibility of text value
--      spacing = spacing between text and icon
return function(args)
    local widget = wibox.widget {
        {
            id = 'place',
            {
                id = 'icon',
                image = args.icons[1],
                resize = args.resize,
                widget = wibox.widget.imagebox
            },
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place,
        },
        {
            id = 'text',
            text = 'null',
            font = args.font,
            visible = args.show_text or false,
            widget = wibox.widget.textbox
        },
        buttons = args.buttons,
        held_percent = 0,
        spacing = args.spacing or 2,
        icons = args.icons,
        layout = wibox.layout.fixed.horizontal
    }

    widget.set_icon = function(self, image)
        self.place.icon.image = image
    end

    widget.set_text = function(self, text)
        self.text.text = text
    end

    widget.update = function(self)
        -- Implemented per widget
    end

    widget.manual_update = function(self, percent, state)
        local index = math.ceil((percent * #self.icons)/100)
        self.held_percent = percent
        index = index == 0 and 1 or index
        self:set_icon(self.icons[index])
        self:set_text(percent .. '%')
    end

    awesome.connect_signal("widgets::" .. args.name, function()
        widget:update()
    end)

    local tooltip = awful.tooltip {
        objects =  { widget },
        mode = 'outside',
        margins = 5,
        delay_show = 1,
        preferred_alignments  = 'middle',
        timer_function = function() return widget.held_percent .. '%' end
    }

    return widget
end
