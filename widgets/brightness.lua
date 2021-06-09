local awful = require("awful")
local gears = require("gears")
local template = require("widgets.value_widget_template")

-- args:
--      icons = icons to use
--      font = font to use
--      resize = resize icon
return function(args)
    local brightness = template(gears.table.join({ name = "brightness" }, args))

    brightness.update = function(self)
        awful.spawn.easy_async('light',
            function(stdout)
                self:manual_update(math.floor(tonumber(stdout)))
            end
        )
    end

    return brightness
end
