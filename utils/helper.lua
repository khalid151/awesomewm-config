local awful = require("awful")
local gears = require("gears")

local helper = {}

helper.add_tags = function(screen, args)
    for _,t in ipairs(args) do
        if not t.properties then t.properties = {} end
        t.properties['screen'] = screen
        awful.tag.add(t.name, t.properties)
    end
end

helper.add_keybindings = function(keys)
    local keys_list = {}
    local modifiers = {
        alt = "Mod1",
        control = "Control",
        super = "Mod4",
        shift = "Shift",
    }

    for i,key in ipairs(keys) do
        if getmetatable(key) == nil then
            local mods = {}
            local binding = nil
            for _,k in ipairs(gears.string.split(key[1], "+")) do
                if modifiers[k] ~= nil then
                    mods[#mods+1] = modifiers[k]
                else
                    binding = k
                end
            end
            keys_list[i] = awful.key(mods, binding, key[2], {description=key[3], group=key[4]})
        else
            -- pretend it's awful.key
            keys_list[i] = key
        end
    end
    return keys_list
end

helper.cache_icons = function(pack_name, sizes)
    local sizes = sizes or "24x24;"
    local icons = {}
    for size in sizes:gmatch("([^;]+)") do
        icons[size] = {}
        awful.spawn.with_line_callback(
            string.format("find /usr/share/icons/%s/%s -name '*.svg'", pack_name, size), {
            stdout = function(line)
                local icon_name = string.match(line, '.*/(.+).svg')
                if icon_name then
                    icons[size][icon_name] = line
                end
            end,
        })
    end
    return icons
end

helper.icon_surface = function(icon_path)
    local icon = gears.surface(icon_path)
    return icon._native
end

helper.delayed_focus_signal = gears.timer {
    timeout = 0.01,
    single_shot = true,
    callback = function()
        client.emit_signal("check_focused")
    end
}

return helper
