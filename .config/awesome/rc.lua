local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
vicious = require("vicious")
require("gears.wallpaper").set(require("gears.color")("#000000"))

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

terminal = "st"
--exec = awful.util.spawn
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
function red(str) return string.format('<span color="#f77">%s</span>', str) end
function yellow(str) return string.format('<span color="#bb4">%s</span>', str) end
function space(n, str) return string.format('%'..n..'s', str) end

sep = wibox.widget.textbox()
sep:set_text("   ")

local cpu_count = 0
for line in io.lines("/proc/stat") do
    if string.match(line, "^cpu[%d]+") then cpu_count = cpu_count + 1 end
end

cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
    local txt=""
    for cn=1, cpu_count do
        txt = txt..space(4, args[cn])
    end
    return txt
end, 1)

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
    if args[1] == "−" then
        if args[2] < 10 then
            return red(space(3, args[2].."!!"))..space(6, args[3])
        end
        if args[2] < 20 then
            return red(space(3, args[2].."!"))..space(6, args[3])
        end
        return space(3, args[2])..space(6, args[3])
    end
    if args[1] == '+' then
        return green(space(3, args[2]))..space(6, args[3])
    end
    if args[1] == '↯' then
        return green(space(3, args[2])).." 00:00"
    end
    return green(space(3, args[2])).." ??:??"
end, 4, "BAT0")

blwidget = wibox.widget.textbox()
local backlight = 0

function round(number)
    local floor = math.floor(number)
    if number - floor >= 0.5 then
        return floor + 1
    end
    return floor
end

function backlight_get()
    local f = io.popen("xbacklight -get")
    backlight = round(f:read("*n"))
    f:close()
    blwidget:set_text(space(3, tostring(backlight)))
end
backlight_get()

function betw(val, min, max)
    if val < min then
        return min
    end
    if val > max then
        return max
    end
    return val
end

function backlight_inc(increasing)
    local num = 1 + math.floor(backlight / 20.0)
    if num % 2 == 1 then num = num + 1 end
    if not increasing then
        num = -num
    end
    backlight = betw(backlight + num, 0, 100)
    sexec(string.format("xbacklight -set %d", backlight))
    blwidget:set_text(space(3, tostring(backlight)))
end

volwidget = wibox.widget.textbox()
local volume = 0
local volume_muted = true

function volume_upd()
    if volume_muted then
        volwidget:set_markup(blue(space(3, tostring(volume))))
    else
        volwidget:set_text(space(3, tostring(volume)))
    end
end

function volume_get()
    local f = io.popen("amixer -M get Master")
    local mixer = f:read("*all")
    f:close()
    local volu, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")
    if volu == nil then return end
    volume = tonumber(volu)
    volume = volume + (5 - (volume % 5))
    volume_muted = mute == "off" or (mute == "" and volume == 0)
    volume_upd()
end
volume_get()

function volume_inc(increasing)
    local num = 5
    if not increasing then
        num = -num
    end
    volume = betw(volume + num, 0, 100)
    sexec(string.format("amixer -M -q set Master %d%%", volume))
    volume_upd()
end

function volume_mute(increasing)
    volume_muted = not volume_muted
    sexec("amixer -q set Master toggle")
    volume_upd()
end

memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem,
function (widget, args)
    local used = yellow(space(5, args[2]))
    local nonfree = blue(space(4, args[9]))
    local total = green(space(-5, args[3]))
    return used..' '..nonfree..' '..total
end, 1)

local devices

iowidget = wibox.widget.textbox()
vicious.register(iowidget, vicious.widgets.dio,
function (widget, args)
    local txt = ""
    devices = { }
    for line in io.lines("/proc/diskstats") do
        local dev = string.match(line, " (sd[a-z]) ")
        if dev ~= nil then table.insert(devices, dev) end
    end
    for i, dev in ipairs(devices) do
        local write = yellow(space(4, args["{"..dev.." write_mb}"]))
        local read = green(space(-4, args["{"..dev.." read_mb}"]))
        if txt ~= "" then txt = txt..'  ' end
        txt = txt..write..' '..dev:sub(3)..' '..read
    end
    return txt
end, 1)

local function wifi_n()
    local f = io.popen("wpa_cli status wlp3s0")
    local o = f:read("*a")
    f:close()
    local name = string.match(o, "id_str=([a-zA-Z0-9_\\-.,]+)")
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
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
    local txt = ""
    for dev, enabled in pairs(net_ifaces) do
        local rx = args['{'..dev..' rx_mb}']
        if rx ~= '0.0' and rx ~= nil then
            net_ifaces[dev] = true
            local up = space(5, args['{'..dev..' up_kb}'])
            local tx = args['{'..dev..' tx_mb}']
            local dn = space(-5, args['{'..dev..' down_kb}'])
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
    "/home/mvdan/mail/mvdan/Inbox/new",
    "/home/mvdan/mail/mvdan/Other/new",
}

function mdir_str()
    local txt = ""
    for i, path in ipairs(maildirs) do
        local f = io.popen("find "..path.." -type f 2>/dev/null | wc -l")
        local count = f:read("*n")
        f:close()
        local sp = 2
        if i > 1 then sp = 3 end
        if count == nil then
            txt = txt.." ?"
        elseif count > 0 then
            txt = txt..green(space(sp, count))
        else
            txt = txt..space(sp, count)
        end
    end
    return txt
end

mdirwidget = wibox.widget.textbox()
function mdirwidget_update()
    mdirwidget:set_markup(mdir_str())
end

function imap_sync()
    if net_ifaces["wlp3s0"] == false and net_ifaces["enp0s25"] == false then
        return
    end
    sexec('mbsync -a -q; notmuch new --quiet')
end

local imap = timer({ timeout = 60 })
imap:connect_signal("timeout", function() imap_sync() end)
imap:start()

local mdirtimer = timer({ timeout = 3 })
mdirtimer:connect_signal("timeout", function() mdirwidget_update() end)
mdirtimer:start()

mdirwidget_update()

function ellipsize(str, l)
    if string.len(str) <= l + 1 then
        return str
    end
    return string.format("%s…", str:sub(1, l))
end

mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd,
function (widget, args)
    if args["{state}"] == "Stop" then return ' - MPD - ' end
    return ellipsize(args["{Title}"], 24)..' - '..ellipsize(args['{Album}'], 20)
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
    bot_left_layout:add(sep)
    bot_left_layout:add(netwidget)
    bot_left_layout:add(sep)
    bot_left_layout:add(mdirwidget)
    bot_left_layout:add(sep)

    local bot_right_layout = wibox.layout.fixed.horizontal()
    bot_right_layout:add(mpdwidget)
    bot_right_layout:add(sep)

    local bot_layout = wibox.layout.align.horizontal()
    bot_layout:set_left(bot_left_layout)
    bot_layout:set_middle()
    bot_layout:set_right(bot_right_layout)
    botwibox[s]:set_widget(bot_layout)
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

    awful.key({ modkey, "Shift"   }, "j",     function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k",     function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j",     function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k",     function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u",     awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",     awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",     awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n",     awful.client.restore),

    awful.key({ modkey, altkey    }, "Down",  function () volume_mute() end),
    awful.key({ modkey, altkey    }, "Left",  function () volume_inc(false) end),
    awful.key({ modkey, altkey    }, "Right", function () volume_inc(true) end),
    awful.key({ modkey, altkey    }, ".",     function () sexec("mpc next; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, ",",     function () sexec("mpc prev; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
    awful.key({ modkey, altkey    }, "-",     function () sexec("mpc toggle") end),
    awful.key({ modkey, altkey    }, "/",     function () sexec("mpc toggle") end),
    awful.key({ modkey, altkey    }, "Up",    function () sexec("slock") end),
    awful.key({ modkey, altkey    }, "Prior", function () backlight_inc(false) end),
    awful.key({ modkey, altkey    }, "Next",  function () backlight_inc(true) end),
    awful.key({ modkey, altkey    }, "1",     function () sexec("setxkbmap us altgr-intl -option caps:none") end),
    awful.key({ modkey, altkey    }, "2",     function () sexec("setxkbmap es cat -option caps:none") end),
    awful.key({ modkey, altkey    }, "h",     function () sexec(terminal .. " -c ssh -e ssh linode -t TERM=screen-256color tmux -u a") end),
    awful.key({ modkey, altkey    }, "j",     function () sexec(terminal .. " -c mutt -e mutt") end),
    awful.key({ modkey, altkey    }, "k",     function () sexec(terminal .. " -c ranger -e zsh -c ranger") end),
    awful.key({ modkey, altkey    }, "n",     function () sexec(terminal .. " -c ncmpc -e ncmpc") end),
    awful.key({ modkey, altkey    }, "i",     function () sexec("chromium") end),

    awful.key({ modkey            }, "s",     function () sexec("maim -s ~/$(date +%F-%T).png") end),
    awful.key({ modkey            }, "i",     function ()
        local f = io.popen("ip route")
        local t = f:read("*a"):sub(0, -2)
        f:close()
        naughty.notify({
            title = " % ip route",
            text = t,
            position = "bottom_right"
        })
    end),

    awful.key({ modkey            }, "r",     function () promptbox[mouse.screen]:run() end),

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

for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then awful.tag.viewonly(tag) end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then awful.tag.viewtoggle(tag) end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then awful.client.movetotag(tag) end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then awful.client.toggletag(tag) end
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
    { rule = { class = "ssh" },
    properties = { tag = tags[1][2] } },
    { rule = { class = "mutt" },
    properties = { tag = tags[1][3] } },
    { rule = { class = "Telegram" },
    properties = { tag = tags[1][7] } },
    { rule = { class = "chromium" },
    properties = { tag = tags[1][8] } },
    { rule = { class = "ranger" },
    properties = { tag = tags[1][9] } },
    { rule = { class = "ncmpc" },
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
