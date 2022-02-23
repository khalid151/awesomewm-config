local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

local helper = {}

helper.debug = function(string)
    naughty.notify { title = "Debug", text = string }
end

helper.wacom_focus = {
    client = function(c)
        awful.spawn("wacom_focus -w " .. c.window)
    end,
    screen = function(s)
        local screen = s or awful.screen.focused()
        local name = gears.table.keys(screen.outputs)[1]
        if name then
            awful.spawn.with_line_callback("wacom_focus -l", {
                stdout = function(o)
                    if o:match(name:gsub("-", "%%-")) then
                        local m = o:match("^(%d+):")
                        awful.spawn("wacom_focus -m " .. m)
                    end
                end,
            })
        end
    end,
}

helper.aspect_ratio = function(screen)
    local geometry = screen.geometry
    return geometry.width / geometry.height
end

helper.add_tags = function(screen, args)
    for _,t in ipairs(args) do
        if not t.properties then t.properties = {} end
        t.properties['screen'] = screen
        if not t.properties['master_fill_policy'] then
            if helper.aspect_ratio(screen) >= 2.37 then
                t.properties.master_fill_policy = 'master_width_factor'
            end
        end
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

helper.insert_into_table_by_id = function(table, items, id)
    local found = false
    local function rec(_table, _items, _id)
        if _table.id == _id then
            for key, value in pairs(_items) do
                _table[key] = value
            end
            found = true
            return
        end

        for _,v in ipairs(_table) do
            if found then break end
            if type(v) == 'table' then
                helper.insert_into_table_by_id(v, _items, _id)
            end
        end
    end
    rec(table, items, id)
end

return helper
