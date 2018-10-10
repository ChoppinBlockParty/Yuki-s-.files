-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local dbus = require("dbus")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local cyclefocus = require('cyclefocus')
-- Should clients be raised during cycling?
cyclefocus.raise_clients = false
-- Should clients be focused during cycling?
cyclefocus.focus_clients = true

-- How many entries should get displayed before and after the current one?
cyclefocus.display_next_count = 5
cyclefocus.display_prev_count = 5  -- only 0 for prev, works better with naughty notifications.
-- cyclefocus.naughty_preset.position = ''
-- local switcher = require("awesome-switcher-preview")
-- switcher.settings.preview_box = true                                 -- display preview-box
-- switcher.settings.preview_box_bg = "#ddddddaa"                       -- background color
-- switcher.settings.preview_box_border = "#22222200"                   -- border-color
-- switcher.settings.preview_box_fps = 30                               -- refresh framerate
-- switcher.settings.preview_box_delay = 10                             -- delay in ms
-- switcher.settings.preview_box_title_font = {"sans","italic","normal"}-- the font for cairo
-- switcher.settings.preview_box_title_font_size_factor = 0.8           -- the font sizing factor
-- switcher.settings.preview_box_title_color = {0,0,0,1}                -- the font color

-- switcher.settings.client_opacity = true                             -- opacity for unselected clients
-- switcher.settings.client_opacity_value = 0.8                         -- alpha-value
-- switcher.settings.client_opacity_delay = 150
local my = require('MyScripts')

-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

my.RunOnce('nm-applet')
my.RunOnce('xscreensaver -no-splash')
my.RunOnce('setxkbmap us,ru && kbdd')
my.RunOnce('parcellite -d')
my.RunOnce('xset r rate 200 40')

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "env -u TMUX urxvt"
editor = os.getenv("EDITOR") or "editor"
-- editor_cmd = terminal .. " -e " .. editor
editor_cmd = 'env -u TMUX ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.spiral,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[3])
end
-- }}}

globalkeys = awful.util.table.join(
  awful.key({ modkey }, "F8",
    function ()
      my.spawn_once("thunderbird", "Thunderbird", tags[1][2])
      my.spawn_once("pidgin", "Pidgin", tags[1][2])
      -- my.spawn_once("env -u TMUX urxvt -e env RUNTHISCOMMAND=\"prj && e&\" zsh -il", "urxvt", tags[1][4])
      -- my.spawn_once("env -u TMUX urxvt -e env RUNTHISCOMMAND=\"rmg && e&\" zsh -il", "urxvt", tags[1][7])
      -- my.spawn_once("env -u TMUX urxvt -e env RUNTHISCOMMAND=\"spr && e&\" zsh -il", "urxvt", tags[1][8])
      -- my.spawn_once("env -u TMUX urxvt -e env RUNTHISCOMMAND=\"grg && e&\" zsh -il", "urxvt", tags[1][9])
    end))

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
mytextclock = awful.widget.textclock()

batterywidget = wibox.widget.textbox()
batterywidget_timer = timer({timeout = 2})
batterywidget_timer:connect_signal("timeout", function()
  batterywidget:set_text(my.battery.info())
end)
batterywidget_timer:start()

kbdwidget = wibox.widget.textbox("Eng")
kbdwidget.border_width = 1
kbdwidget.border_color = beautiful.fg_normal
kbdwidget:set_text("Eng")

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
  local data = {...}
  local layout = data[2]
  lts = {[0] = "Eng", [1] = "Рус"}
  kbdwidget:set_text(lts[layout])
  end)

-- kbd_dbus_sw_cmd = "qdbus ru.gentoo.KbddService /ru/gentoo/KbddService  ru.gentoo.kbdd.set_layout "
-- kbd_dbus_sw_cmd = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:"
-- kbd_dbus_prev_cmd = "qdbus ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.prev_layout"
kbd_dbus_prev_cmd = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.prev_layout"
-- kbd_dbus_next_cmd = "qdbus ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.next_layout"
kbd_dbus_next_cmd = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.next_layout"

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1,
                      function(tag)
                        local i = awful.tag.getidx(tag)
                        for screen = 1, screen.count() do
                            local tag = awful.tag.gettags(screen)[i]
                            if tag then
                               awful.tag.viewonly(tag)
                            end
                        end
                      end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    -- left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(batterywidget)
    right_layout:add(kbdwidget)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local scratch = require("scratch")
-- {{{ Key bindings
globalkeys = awful.util.table.join(globalkeys,
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 15") end),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 15") end),
    awful.key({}, "F1",      function () scratch.drop(terminal, "top", "center", 1, 0.47, true) end),
    awful.key({modkey}, "Left",   awful.tag.viewprev       ),
    awful.key({modkey}, "Right",  awful.tag.viewnext       ),
    awful.key({modkey}, "Escape", awful.tag.history.restore),
    awful.key({modkey}, "n",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({modkey, "Shift"}, "n",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({modkey}, "j", function () awful.screen.focus_relative(1) end),
    awful.key({modkey}, "k", function () awful.screen.focus_relative(-1) end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),

    awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster( 1, null, true) end),
    awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster(-1, null, true) end),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol( 1)          end),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol(-1)          end),
    awful.key({ modkey,           }, "b", function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "b", function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    awful.key({modkey, "Shift"}, "z", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),
    -- Menubar
    awful.key({ modkey }, "space", function() menubar.show() end),
    awful.key({"Mod1"}, "Shift_L", function() os.execute(kbd_dbus_next_cmd) end),
    awful.key({"Shift"}, "Alt_L", function() os.execute(kbd_dbus_next_cmd) end),
    -- awful.key({ "Mod1" }, "Tab",
    --   function ()
    --       awful.client.focus.byidx(1)
    --       if awful.client.ismarked() then
    --           awful.screen.focus_relative(-1)
    --           awful.client.getmarked()
    --       end
    --       if client.focus then
    --           client.focus:raise()
    --       end
    --       awful.client.togglemarked()
    --   end),
    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run({ prompt = "Run Lua code: " },
    --               mypromptbox[mouse.screen].widget,
    --               awful.util.eval, nil,
    --               awful.util.getdir("cache") .. "/history_eval")
    --           end),
    -- awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    -- awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey            }, "u", function() awful.client.swap.byidx(  1) end),
    awful.key({ modkey, "Shift"   }, "u", function() awful.client.swap.byidx( -1) end),
    awful.key({ modkey,           }, "i", function()
      awful.client.getmaster()
      client.focus:raise()
    end)
)

clientkeys = awful.util.table.join(
  awful.key({modkey}, "f", function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({modkey}, "m", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({modkey}, "o", awful.client.movetoscreen                        ),
  awful.key({modkey}, "0",
      function (c)
          -- The client currently has the input focus, so it cannot be
          -- minimized, since minimized clients can't have the focus.
          c.minimized = true
      end),
  awful.key({ modkey }, "`", function (c) c:kill() end),
  awful.key({ modkey }, "z",
      function (c)
        awful.titlebar.toggle(c)
        if c.maximized_vertical then
          c.maximized_horizontal = not c.maximized_horizontal
          c.maximized_vertical   = not c.maximized_vertical
          c.maximized_horizontal = not c.maximized_horizontal
          c.maximized_vertical   = not c.maximized_vertical
        end
      end),
  awful.key({ modkey }, "x",
      function (c)
          c.maximized_horizontal = not c.maximized_horizontal
          c.maximized_vertical   = not c.maximized_vertical
      end),
  awful.key({ modkey }, "c", awful.client.floating.toggle),
  cyclefocus.key({ "Mod1", }, "Tab", 1, {
      cycle_filters = { my.same_tag_name },
      keys = {'Tab', 'ISO_Left_Tab'}  -- default, could be left out
  })
  -- -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
  -- awful.key({"Mod1"}, "Tab", function() switcher.switch(1, "Alt_L", "Tab", "ISO_Left_Tab") end),
  -- awful.key({"Mod1", "Shift"}, "Tab", function() switcher.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab") end)
  -- Переключение по всем окнам по комбинации Win+Tab
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
workSpaceKeys = {"1", "2", "3", "q", "w", "e", "a", "s", "d", "0"}
screen_history = {}
for i = 1, 9 do
  screen_history[i] = 1
end
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, workSpaceKeys[i],
          function ()
            if client.focus then
              screen_history[awful.tag.getidx(awful.tag.selected(client.focus.screen))] = client.focus.screen
            end
            local current_screen = screen_history[i]
            local tag = awful.tag.gettags(current_screen)[i]
            if tag then awful.tag.viewonly(tag) end
            local c = nil
            if client.focus then c = client.focus end
            for screen_i = 1, screen.count() do
              if screen_i == current_screen then else
                local tag = awful.tag.gettags(screen_i)[i]
                if tag then awful.tag.viewonly(tag) end
              end
            end
            if c then awful.client.focus.byidx(0, c) end
          end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, workSpaceKeys[i],
          function ()
              local screen = mouse.screen
              local tag = awful.tag.gettags(screen)[i]
              if tag then
                 awful.tag.viewtoggle(tag)
              end
          end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, workSpaceKeys[i],
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, workSpaceKeys[i],
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

gloabalkeys = awful.util.table.join(
   gloabalkeys,
   awful.key({}, "XF86Display", xrandr))
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     size_hints_honor = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Xfce4-appfinder" },
      properties = { floating = true } },
    { rule = { class = "Xfce4-panel" },
      properties = { floating = true } },
    { rule = { class = "guake" },
      properties = { floating = true } },
    { rule = { class = "Meld" },
      properties = {floating = false, maximized_vertical = false, maximized_horizontal = false}},
    -- Set Firefox to always map on tags number 2 of screen 1.
    {rule = { class = "Firefox" }, properties = {floating=false}}
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count change
        awful.placement.no_offscreen(c)
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
        awful.titlebar.toggle(c)
        if c.maximized_vertical then
          c.maximized_horizontal = not c.maximized_horizontal
          c.maximized_vertical   = not c.maximized_vertical
          c.maximized_horizontal = not c.maximized_horizontal
          c.maximized_vertical   = not c.maximized_vertical
        end
    end
end)

client.connect_signal("focus", function(c)
  local clients_count = 0
  for s = 1, screen.count() do
    local tag = awful.tag.selected(s)
    if tag then
      clients_count = clients_count + table.getn(tag:clients())
    end
  end
  -- naughty.notify({
  --           -- TODO: use indenting
  --           -- text = tostring(msg)..' ['..tostring(level)..']',
  --           text = tostring(awful.layout.getname(awful.layout.get(c.screen))),
  --           timeout = 10,
  --         })
  local layout_name = awful.layout.getname(awful.layout.get(c.screen))
  if clients_count < 2 or layout_name == "fullscreen" or c.fullscreen or c.maximized == true  then
    c.border_width = "0"
    c.border_color = beautiful.border_focus
  else
    -- c.border_width = "1"
    c.border_color = beautiful.border_focus
    -- c.border_color =  "#AA330000"
  end
end)
client.connect_signal("unfocus", function(c)
  c.border_width = "0"
  -- c.border_color = beautiful.border_normal
end)
-- }}}

-- {{{ Random Wallpapers
-- Get the list of files from a directory. Must be all images or folders and non-empty. 
function scanDir(directory)
  local i, fileList, popen = 0, {}, io.popen
  for filename in popen([[find "]] ..directory.. [[" -type f]]):lines() do
      i = i + 1
      fileList[i] = filename
  end
  return fileList
end

-- Apply a random wallpaper on startup.
wallpaperList = scanDir(os.getenv("HOME").."/Data/Wallpapers/Wow")
gears.wallpaper.maximized(wallpaperList[math.random(1, #wallpaperList)], s, true)

-- Apply a random wallpaper every changeTime seconds.
local wallpaperDir = os.getenv("HOME").."/Data/Wallpapers/Black"
local wallpaperList = scanDir(wallpaperDir)
local function setWallpaper()
  local wallpaperPath = wallpaperList[math.random(1, #wallpaperList)]
  for s = 1, screen.count() do
      gears.wallpaper.maximized(wallpaperPath, s, true)
  end
end
setWallpaper()
changeTime = 120
wallpaperTimer = timer { timeout = changeTime }
wallpaperTimer:connect_signal("timeout", function()
  setWallpaper()
  -- stop the timer (we don't need multiple instances running at the same time)
  wallpaperTimer:stop()
  --restart the timer
  wallpaperTimer.timeout = changeTime
  wallpaperTimer:start()
    -- If wallpaper is a function, call it with the screen
end)

-- initial start when rc.lua is first run
wallpaperTimer:start()
-- }}}
