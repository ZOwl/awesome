--
--------------------------------------------------------------------------------
--         FILE:  awesome.lua
--        USAGE:  ./awesome.lua 
--  DESCRIPTION:  
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  ZOwl (<>), <zhhbug@gmail.com>
--      COMPANY:  BIT
--      VERSION:  1.0
--      CREATED:  05/10/2010 03:12:02 PM CST
--     REVISION:  ---
--------------------------------------------------------------------------------
--

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load debian menu entries
--require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
theme_path = os.getenv("HOME").."/.config/awesome/themes/Glossy"
beautiful.init(theme_path.."/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- revelation
require("revelation")

-- eminent
require("eminent")

-- Delightful widgets
require('delightful.widgets.battery')
require('delightful.widgets.cpu')
require('delightful.widgets.datetime')
--require('delightful.widgets.imap')
require('delightful.widgets.memory')
require('delightful.widgets.network')
require('delightful.widgets.pulseaudio')
--require('delightful.widgets.weather')

-- Which widgets to install?
-- This is the order the widgets appear in the wibox.
install_delightful = {
    delightful.widgets.network,
    delightful.widgets.cpu,
    delightful.widgets.memory,
    --delightful.widgets.weather,
    --delightful.widgets.imap,
    delightful.widgets.pulseaudio,
    delightful.widgets.datetime,
    delightful.widgets.battery
}

-- Widget configuration
delightful_config = {
    [delightful.widgets.cpu] = {
        command = 'gnome-system-monitor',
    },
    --[delightful.widgets.imap] = {
    --    {
    --        user      = 'zhhbug@gmail.com',
    --        password  = 'zhhsaws',
    --        host      = 'imap.google.com',
    --        ssl       = true,
    --        mailboxes = { 'INBOX', 'awesome' },
    --        command   = 'evolution -c mail',
    --    },
    --},
    [delightful.widgets.memory] = {
        command = 'gnome-system-monitor',
    },
    [delightful.widgets.battery] = {
        battery = 'BAT0',
    },
    -- [delightful.widgets.weather] = {
    --     {
    --         city = 'Beijing',
    --         command = 'gnome-www-browser http://ilmatieteenlaitos.fi/saa/Beijing',
    --     },
    -- },
    [delightful.widgets.pulseaudio] = {
        mixer_command = 'gnome-volume-control',
    },
}

-- Prepare the container that is used when constructing the wibox
local delightful_container = { widgets = {}, icons = {} }
if install_delightful then
    for _, widget in pairs(awful.util.table.reverse(install_delightful)) do
        local config = delightful_config and delightful_config[widget]
        local widgets, icons = widget:load(config)
        if widgets then
            if not icons then
                icons = {}
            end
            table.insert(delightful_container.widgets, awful.util.table.reverse(widgets))
            table.insert(delightful_container.icons,   awful.util.table.reverse(icons))
        end
    end
end

-- This is used later as the default terminal and editor to run.
browser = "google-chrome"
terminal = "rxvt-unicode"
terminal_for_dev = terminal .. " +sb"
terminal_with_tmux = terminal .. " -e tmux"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
dmenu = "dmenu_run -b -fn 'CodingFontTobi-10' -nb '#333333' -nf '#ffffff' -sb '#1793d1' -sf '#ffffff'"
rox = "rox"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

-- Tags
gold_number    = 0.618033988769
default_mwfact = gold_number
tags_name   = { "main", "www", "mail", "irc", "im", "music", "dev", "admin", "foo", "bar", "baz", "qux" }
tags_layout = { 1, 1, 1, 4, 9, 4, 1, 1, 1, 1, 1, 1 }
tags_mwfact = { gold_number, gold_number, gold_number, (1 - gold_number), gold_number, (1 - gold_number), gold_number, gold_number, gold_number, gold_number, gold_number }

-- }}}

-- {{{ Tags
-- Define tags table
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table
    tags[s] = {}
    -- Create all tags on each screen
    for id, name in ipairs(tags_name) do
        tags[s][id] = tag { name = name }
        -- Add tags to screen one by one
        tags[s][id].screen = s
        awful.layout.set(layouts[tags_layout[id] or tags_layout[1]], tags[s][id])
        if tags_mwfact[#tags[s]] then
            awful.tag.setmwfact(tags_mwfact[id], tags[s][id])
        else
            awful.tag.setmwfact(default_mwfact, tags[s][id])
        end
    end
    -- I'm sure you want to see at least one tag.
    tags[s][1].selected = true
end

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

mymainmenu = awful.menu({ 
    items = { 
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        --{ "Debian", debian.menu.Debian_menu.Debian },
        { "Log out", '/home/zhonghao/bin/shutdown_dialog.sh' },
        { "open terminal", terminal }
    }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mystatusbar = {}
infobox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
    if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
    end
    client.focus = c
    c:raise()
end),
awful.button({ }, 3, function ()
    if instance then
        instance:hide()
        instance = nil
    else
        instance = awful.menu.clients({ width=250 })
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
        return awful.widget.tasklist.label.currenttags(c, s)
    end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    local widgets_front = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
    }
    local widgets_middle = {}
    for delightful_container_index, delightful_container_data in pairs(delightful_container.widgets) do
        for widget_index, widget_data in pairs(delightful_container_data) do
            table.insert(widgets_middle, widget_data)
            if delightful_container.icons[delightful_container_index] and delightful_container.icons[delightful_container_index][widget_index] then
                table.insert(widgets_middle, delightful_container.icons[delightful_container_index][widget_index])
            end
        end
    end
    local widgets_end = {
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    mywibox[s].widgets = awful.util.table.join(widgets_front, widgets_middle, widgets_end)

    -- Bottom Box
    --mystatusbar = awful.wibox({ position = "bottom", screen = s, ontop = false, width = 1, height = 16 })
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
    ))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
    function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "k",
    function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "e", revelation.revelation ),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",

    function ()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end),

    -- Standard program
    awful.key({ modkey,           }, "t",      function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "d",      function () awful.util.spawn(terminal_for_dev) end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal_with_tmux) end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal_alt) end),
    awful.key({ modkey,           }, "e",      function () awful.util.spawn(editor_cmd) end),
    awful.key({ modkey,           }, "b",      function () awful.util.spawn(browser) end),
    awful.key({ modkey,           }, "p",      function () awful.util.spawn(dmenu) end),
    awful.key({ modkey,           }, "g",      function () awful.util.spawn(rox) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
    function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end),

    -- Programs
    awful.key({ modkey, "Control" }, "s", function () awful.util.spawn("xscreensaver-command -lock") end)
    -- awful.key(k_m,  "m",      function () awful.util.spawn(mail) end),
    -- awful.key(k_m,  "i",      function () awful.util.spawn(im) end),
    -- awful.key(k_m,  "z",      function () awful.util.spawn(music) end),
    -- awful.key(k_mc, "End",    function () awful.util.spawn(xlock) end),
    -- awful.key(k_ms, "F5",     function () awful.util.spawn(setup_mono) end),
    -- awful.key(k_ms, "F6",     function () awful.util.spawn(setup_dual) end),
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
    function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
    keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewtoggle(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            keys = clientkeys,
            buttons = clientbuttons 
        } 
    },
    -- { rule = { class = "MPlayer" },
    --  properties = { floating = true } },
    --{ rule = { class = "pidgin" }, properties = { tag = tags[1][7] } },
    { rule = { class = "Shredder" }, properties = { tag = tags[1][9] } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { instance = "firefox" }, properties = { tag = tags[1][2] } }, 
    { rule = { instance = "google-chrome" }, properties = { tag = tags[1][2] } }, 
    { rule = { instance = "pidgin" }, properties = { tag = tags[1][5] } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    -- Deal with window gaps
    c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
--client.add_signal("focus", function(c)
--                              c.border_color = beautiful.border_focus
--                              c.opacity = 1
--                           end)
--client.add_signal("unfocus", function(c)
--                                c.border_color = beautiful.border_normal
--                                c.opacity = 0.7
--                             end)
-- }}}

-- {{{ Timers
-- /tmp/mail
--[[
aurhook = timer { timeout = 880 }
aurhook:add_signal("timeout", function()
os.execute("ruby /home/tim/bin/mail.rb > /tmp/mail")
end)
aurhook:start()
--]]
-- }}}

-- {{{ Autorun
-- autorun applications
autorun = false
autorunApps = 
{
    --"gnome-settings-daemon",
    "nm-applet --sm-disable",
    --"update-notifier",
    --"gnome-do",
    --"feh --bg-center /usr/share/backgrounds/Icystones2.jpg",
    --"xscreensaver -nosplash",
    --"halevt",
    --"stalonetray",
    --"xrandr --output VGA1 --mode 1440x900 --rotate left --left-of HDMI1 --output HDMI1 --mode 1920x1080", 
    "urxvtd",
    "ibus-daemon -d -x -r",
    --"xcompmgr -Ss -n -Cc -fF -I-10 -O-10 -D1 -t-3 -l-4 -r4", 
    --"wmname LG3D",
    "xset -b"
    --"conky"
}

if autorun then
    for app = 1, #autorunApps do
        awful.util.spawn(autorunApps[app])
    end
end
-- }}}

-- vim:ts=4 sw=4 sts=4 et
