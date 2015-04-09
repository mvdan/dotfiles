local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
require("gears.wallpaper").set(require("gears.color")("#000000"))

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

terminal = "st"
exec = awful.util.spawn
sexec = awful.util.spawn_with_shell

modkey = "Mod4"
altkey = "Mod1"

local layouts = {
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.magnifier,
    awful.layout.suit.max.fullscreen,
}

tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }, s, layouts[1])
end

menubar.utils.terminal = terminal

datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, " %b %d, %T ", 1)

topwibox = {}
botwibox = {}
promptbox = {}
layoutbox = {}
taglist = {}
tasklist = {}

function green(str) return string.format('<span color="#4c4">%s</span>', str) end
function blue(str) return string.format('<span color="#77f">%s</span>', str) end
function yellow(str) return string.format('<span color="#bb4">%s</span>', str) end
function space(n, str) return string.format('%'..n..'s', str) end

local sep = wibox.widget.textbox()
sep:set_text("    ")

local cpu_count = 0
for line in io.lines("/proc/stat") do
    if string.match(line, "^cpu[%d]+") then cpu_count = cpu_count + 1 end
end

local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
    local txt=""
    for cn=1, cpu_count do
        txt = txt..space(4, args[cn])
    end
    return txt
end, 1)

local batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
    if args[1] == "−" then
        return space(3, args[2])..space(6, args[3])
    elseif args[1] == '+' then
        return green(space(3, args[2]))..space(6, args[3])
    elseif args[1] == '↯' then
        return green(space(3, args[2])).." 00:00"
    else
        return green(space(3, args[2])).." ??:??"
    end
end, 4, "BAT0")

local blwidget = wibox.widget.textbox()

local volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, function(widget, args)
    if args[2] == "♫" then
        return space(3, args[1])
    else
        return blue(space(3, args[1]))
    end
end, 4, "Master")

local memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem,
function (widget, args)
    local used = yellow(space(5, args[2]))
    local nonfree = blue(space(4, args[9]))
    local total = green(space(-5, args[3]))
    return used..' '..nonfree..' '..total
end, 1)

local devices

function add_dev(dev)
    for i, dev_ in ipairs(devices) do
        if dev == dev_ then return end
    end
    table.insert(devices, dev)
end

local iowidget = wibox.widget.textbox()
vicious.register(iowidget, vicious.widgets.dio,
function (widget, args)
    local txt = ""
    devices = { 'a' }
    for line in io.lines("/proc/mounts") do
        if line:sub(1, 7) == "/dev/sd" then
            add_dev(line:sub(8, 8))
        end
    end
    for i, dev in ipairs(devices) do
        dev = "sd"..dev
        local write = yellow(space(5, args["{"..dev.." write_mb}"]))
        local read = green(space(-5, args["{"..dev.." read_mb}"]))
        if txt ~= "" then txt = txt..'  ' end
        txt = txt..write..' '..dev..' '..read
    end
    return txt
end, 1)

local function wifi_n()
    local name = io.popen("wpa_cli status wlp3s0 | sed -n 's/^id_str=//p'"):read("*l")
    if name ~= nil then return name end
    return "??"
end

local function wifi_q()
    for line in io.lines("/proc/net/wireless") do
        if line:sub(1, 6) == 'wlp3s0' then
            return string.match(line, "([%d]+)[.]")
        end
    end
    return "??"
end

local net_ifaces = { enp0s25 = false, wlp3s0 = false, enp0s20u1 = false, enp0s20u2 = false }
local netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
    local txt = ""
    for dev, enabled in pairs(net_ifaces) do
        local rx = args['{'..dev..' rx_mb}']
        if dev == 'wlp3s0' or (rx ~= '0.0' and rx ~= nil) then
            net_ifaces[dev] = true
            local up = space(5, args['{'..dev..' up_kb}'])
            local tx = args['{'..dev..' tx_mb}']
            local dn = space(-6, args['{'..dev..' down_kb}'])
            if dev == 'wlp3s0' then
                txt = txt..yellow(up)..' '..tx..' '..wifi_n()..' '..wifi_q()..' '..rx..' '..green(dn)
            else
                txt = txt..yellow(up)..' '..tx..' '..dev..' '..rx..' '..green(dn)
            end
        end
    end
    return txt
end, 1)

local maildirs = {
    dan = {
        "/home/mvdan/Mail/linode/INBOX/new",
        "/home/mvdan/Mail/linode/Univ/new",
    },
    cau = {
        "/home/mvdan/Mail/linode/Cau/new",
    }
}
function mdir_str(name)
    local paths = maildirs[name]
    local count = io.popen("find "..table.concat(paths, " ").." -type f 2>/dev/null | wc -l"):read("*n")
    if count == nil then
        return name.." ?"
    end
    if count > 0 then
        return name..' '..green(space(-3, count))
    end
    return name.." "..space(-3, count)
end

local mdirwidget = wibox.widget.textbox()
function mdirwidget_update()
    mdirwidget:set_markup(mdir_str("dan")..mdir_str("cau"))
end

function offlineimap_run(force)
    if net_ifaces["wlp3s0"] == false and net_ifaces["eth0"] == false then
        return
    end
    sexec('offlineimap &>/dev/null; notmuch new &>/dev/null; echo \\"mdirwidget_update()\\" | awesome-client')
end

local imap = timer({ timeout = 60 })
imap:connect_signal("timeout", function() offlineimap_run(false) end)
imap:start()

local mdirtimer = timer({ timeout = 3 })
mdirtimer:connect_signal("timeout", function() mdirwidget_update() end)
mdirtimer:start()

mdirwidget_update()

local mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd,
function (widget, args)
    if args["{state}"] == "Stop" then
        return '  - MPD -  '
    end
    return args["{Title}"]..' - '..args['{Album}']
end, 5)

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt()
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)))
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

    tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons)

    topwibox[s] = awful.wibox({ position = "top", screen = s })

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(taglist[s])
    left_layout:add(promptbox[s])

    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(datewidget)
    right_layout:add(layoutbox[s])

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(tasklist[s])
    layout:set_right(right_layout)

    topwibox[s]:set_widget(layout)

    botwibox[s] = awful.wibox({ position = "bottom", screen = s })

    local bot_left_layout = wibox.layout.fixed.horizontal()
    bot_left_layout:add(sep)
    bot_left_layout:add(cpuwidget)
    bot_left_layout:add(sep)
    bot_left_layout:add(blwidget)
    bot_left_layout:add(sep)
    bot_left_layout:add(batwidget)
    bot_left_layout:add(sep)
    bot_left_layout:add(volwidget)
    bot_left_layout:add(sep)
    bot_left_layout:add(memwidget)
    bot_left_layout:add(sep)
    bot_left_layout:add(iowidget)

    local bot_right_layout = wibox.layout.fixed.horizontal()
    bot_right_layout:add(netwidget)
    bot_right_layout:add(sep)
    bot_right_layout:add(mdirwidget)
    bot_right_layout:add(sep)
    bot_right_layout:add(mpdwidget)
    bot_right_layout:add(sep)
    bot_right_layout:add(sep)

    local bot_layout = wibox.layout.align.horizontal()
    bot_layout:set_left(bot_left_layout)
    bot_layout:set_middle()
    bot_layout:set_right(bot_right_layout)
    botwibox[s]:set_widget(bot_layout)
end

function round(number)
    local floor = math.floor(number)
    if number - floor >= 0.5 then
        return floor + 1
    end
    return floor
end

local backlight = round(io.popen("xbacklight -get"):read("*n"))
blwidget:set_text(tostring(backlight))

function backlight_inc(increasing)
    if increasing and backlight >= 100 then
        return
    end
    if not increasing and backlight <= 0 then
        return
    end
    local num = 1 + math.floor(backlight / 20.0)
    if not increasing then
        num = -num
    end
    backlight = backlight + num
    exec(string.format("xbacklight -set %d", backlight))
    blwidget:set_text(tostring(backlight))
end

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

    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
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

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey, altkey    }, "Down",     function () sexec("amixer -q set Master toggle ; echo \'vicious.force({volwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, "Left",     function () sexec("amixer -M -q set Master 5%- ; echo \'vicious.force({volwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, "Right",    function () sexec("amixer -M -q set Master 5%+ ; echo \'vicious.force({volwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, ".",        function () sexec("mpc next; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, ",",        function () sexec("mpc prev; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, "-",        function () exec("mpc toggle") end),
    awful.key({ modkey, altkey    }, "/",        function () exec("mpc toggle") end),
    awful.key({ modkey, altkey    }, "Up",       function () exec("slock") end),
    awful.key({ modkey, altkey    }, "Prior",    function () backlight_inc(false) end),
    awful.key({ modkey, altkey    }, "Next",     function () backlight_inc(true) end),
    awful.key({ modkey, altkey    }, "1",        function () exec("setxkbmap us altgr-intl -option caps:none") end),
    awful.key({ modkey, altkey    }, "2",        function () exec("setxkbmap es cat -option caps:none") end),
    awful.key({ modkey, altkey    }, "h",        function () exec(terminal .. " -c ssh_mvdan -e ssh linode -t TERM=screen-256color tmux -u a") end),
    awful.key({ modkey, altkey    }, "j",        function () exec(terminal .. " -c mutt -e mutt") end),
    awful.key({ modkey, altkey    }, "k",        function () exec(terminal .. " -c ranger -e zsh -c ranger") end),
    awful.key({ modkey, altkey    }, "n",        function () exec(terminal .. " -c ncmpc -e ncmpc") end),
    awful.key({ modkey, altkey    }, "i",        function () exec("chromium") end),

    awful.key({ modkey            }, "i", function ()
        naughty.notify({
            title = " % ip route",
            text = io.popen("ip route"):read("*a"):sub(0, -2),
            position = "bottom_right"
        })
    end),

    awful.key({ modkey, "Shift"   }, "i", function () exec("sudo systemctl restart netctl-auto@wlp3s0") end),
    
    awful.key({ modkey, altkey    }, "o", function () offlineimap_run(true) end),

    awful.key({ modkey },            "r",     function () promptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  promptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
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

root.keys(globalkeys)

awful.rules.rules = {
    { rule = { },
    properties = { border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        size_hints_honor = false,
        keys = clientkeys,
        buttons = clientbuttons } },
    { rule = { instance = "ssh_mvdan" },
    properties = { tag = tags[1][2] } },
    { rule = { instance = "mutt" },
    properties = { tag = tags[1][3] } },
    { rule = { class = "Chromium" },
    properties = { tag = tags[1][8] } },
    { rule = { instance = "ranger" },
    properties = { tag = tags[1][9] } },
    { rule = { instance = "ncmpc" },
    properties = { tag = tags[1][10] } }
}

client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- vim: et ts=4 sw=4
