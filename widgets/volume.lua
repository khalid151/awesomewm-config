local awful = require("awful")
local gears = require("gears")
local template = require("widgets.value_widget_template")

-- args:
--      icons = icons to use
--      font = font to use
--      resize = resize icon
return function(args)
    local volume = template(gears.table.join({ name = "volume" }, args))

    volume.manual_update = function(self, percent, _)
        self.held_percent = percent
        self:set_text(percent .. '%')
        if not self.muted then
            local index = math.ceil((percent * #self.icons.level)/100)
            index = index == 0 and 1 or index
            self:set_icon(self.icons.level[index])
        else
            self:set_icon(self.icons.muted)
        end
    end

    volume.update = function(self)
        awful.spawn.easy_async('pamixer --get-mute',
            function(status)
                self.muted = status == "true\n"
            end
        )
        awful.spawn.easy_async('pamixer --get-volume',
            function(percent)
                self:manual_update(tonumber(percent))
            end
        )
    end

    return volume
end
