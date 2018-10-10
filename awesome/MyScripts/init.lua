local awful = require("awful")

local my = {}

my.battery = require("MyScripts.battery")

my.same_tag_name = function (c, source_c)
  for _, t in pairs(c:tags()) do
    for _, t2 in pairs(source_c:tags()) do
      if t.name == t2.name then
        return true
      end
    end
  end
  return false
end

my.RunOnce = function(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end


-- {{{
--
-- Autostarting for Awesome <3.4!
-- Add this section to the end of your rc.lua
-- configuration file within ~/.config/awesome/rc.lua
--
-- If you're using Awesome 3.5 change:
--    add_signal -> connect_signal
--    remove_signal --> disconnect_signal
--
-- Thanks to eri_trabiccolo as well as  psychon
--
my.spawn_once = function(command, class, tag)
  -- create move callback
  local callback
  callback = function(c)
    if c.class == class then
      awful.client.movetotag(tag, c)
      client.disconnect_signal("manage", callback)
    end
  end
  client.connect_signal("manage", callback)
  -- now check if not already running!
  local findme = command
  local firstspace = findme:find(" ")
  if firstspace then
    findme = findme:sub(0, firstspace-1)
  end
  -- awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. command .. ")")
  awful.util.spawn_with_shell("(" .. command .. ")")
end

return my
