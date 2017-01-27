-- Tested on Awesome 4.0

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
vicious = require("vicious")
local hotkeys_popup = require("awful.hotkeys_popup").widget

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err) })
		in_error = false
	end)
end

gears.wallpaper.set(gears.color("#002b36"))

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

terminal = "st"
editor = os.getenv("EDITOR") or "neovim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"
altkey = "Mod1"

awful.layout.layouts = {
	awful.layout.suit.max,
	awful.layout.suit.floating,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.top,
}

menubar.utils.terminal = terminal

local sep = wibox.widget.textbox()
sep.text = "   "

local textclock = wibox.widget.textclock()

local function space(n, str)
	return string.format('%'..n..'s', str)
end

local cpu_count = 0
for line in io.lines("/proc/stat") do
	if string.match(line, "^cpu[%d]+") then cpu_count = cpu_count + 1 end
end

local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, function(widget, args)
	local txt=""
	for cn=2, cpu_count+1 do
		txt = txt..space(4, args[cn])
	end
	return txt
end, 1)

local batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
	if args[1] == "−" then
		if args[2] < 10 then
			return space(3, args[2].."!!")..space(6, args[3])
		end
		if args[2] < 20 then
			return space(3, args[2].."!")..space(6, args[3])
		end
		return space(3, args[2])..space(6, args[3])
	end
	if args[1] == '+' then
		return space(3, args[2])..space(6, args[3])
	end
	if args[1] == '↯' then
		return space(3, args[2]).." 00:00"
	end
	return space(3, args[2]).." ??:??"
end, 4, "BAT0")

local blwidget = wibox.widget.textbox()
local backlight = 0

local function round(number)
	local floor = math.floor(number)
	if number - floor >= 0.5 then
		return floor + 1
	end
	return floor
end

local function backlight_get()
	local f = io.popen("xbacklight -get")
	local num = f:read("*n")
	f:close()
	if num ~= nil then
		backlight = round(num)
		blwidget.text = space(3, tostring(backlight))
	end
end
backlight_get()

local function betw(val, min, max)
	if val < min then
		return min
	end
	if val > max then
		return max
	end
	return val
end

local function backlight_inc(increasing)
	local num = 1 + math.floor(backlight / 20.0)
	if num % 2 == 1 then num = num + 1 end
	if not increasing then
		num = -num
	end
	backlight = betw(backlight + num, 0, 100)
	awful.spawn(string.format("xbacklight -set %d", backlight))
	blwidget.text = space(3, tostring(backlight))
end

local volwidget = wibox.widget.textbox()
local volume = 0
local volume_muted = true

local function volume_upd()
	if volume_muted then
		volwidget.text = " - "
	else
		volwidget.text = space(3, tostring(volume))
	end
end

local function volume_get()
	local f = io.popen("amixer -M get Master")
	local mixer = f:read("*all")
	f:close()
	local volu, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")
	if volu == nil then
		return
	end
	volume = tonumber(volu)
	volume = volume + (5 - (volume % 5))
	volume_muted = mute == "off" or (mute == "" and volume == 0)
	volume_upd()
end
volume_get()

local function volume_inc(increasing)
	local num = 5
	if not increasing then
		num = -num
	end
	volume = betw(volume + num, 0, 100)
	awful.spawn(string.format("amixer -M -q set Master %d%%", volume))
	volume_upd()
end

local function volume_mute(increasing)
	volume_muted = not volume_muted
	awful.spawn("amixer -q set Master toggle")
	volume_upd()
end

local memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
	local used = space(5, args[2])
	local nonfree = space(4, args[9])
	local total = space(-5, args[3])
	return used..' '..nonfree..' '..total
end, 1)

local iowidget = wibox.widget.textbox()
vicious.register(iowidget, vicious.widgets.dio, function(widget, args)
	local txt = ""
	for line in io.lines("/proc/diskstats") do
		local dev = string.match(line, " (sd[a-z]) ")
		if dev ~= nil then
			local write = space(4, args["{"..dev.." write_mb}"])
			local read = space(-4, args["{"..dev.." read_mb}"])
			txt = txt..write..' '..dev:sub(3)..' '..read
		end
	end
	return txt
end, 1)

local function wifi_n()
	local f = io.popen("wpa_cli status wlp3s0")
	local o = f:read("*a")
	f:close()
	local name = string.match(o, "id_str=([a-zA-Z0-9_\\-.,]+)")
	if name ~= nil then
		return name
	end
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
vicious.register(netwidget, vicious.widgets.net, function(widget, args)
	local txt = ""
	for dev, enabled in pairs(net_ifaces) do
		local rx = args['{'..dev..' rx_mb}']
		if rx ~= '0.0' and rx ~= nil then
			net_ifaces[dev] = true
			local up = space(5, args['{'..dev..' up_kb}'])
			local tx = args['{'..dev..' tx_mb}']
			local dn = space(-5, args['{'..dev..' down_kb}'])
			if dev == 'wlp3s0' then
				txt = txt..up..' '..tx..' '..wifi_n()..' '..wifi_q()..' '..rx..' '..dn
			else
				txt = txt..up..' '..tx..' '..dev..' '..rx..' '..dn
			end
		end
	end
	return txt
end, 1)

local maildirs = {
	"/home/mvdan/mail/mvdan/Inbox/new",
	"/home/mvdan/mail/mvdan/Other/new",
	"/home/mvdan/mail/mvdan/Go/new",
}

local function mdir_str()
	local total = 0
	for i, path in ipairs(maildirs) do
		local f = io.popen("find "..path.." -type f 2>/dev/null | wc -l")
		local count = f:read("*n")
		f:close()
		if count ~= nil then
			total = total + count
		end
	end
	return space(2, total)
end

local mdirwidget = wibox.widget.textbox()
local imap_enabled = true
imap_running = false
function mdir_update()
	if imap_enabled and not imap_running then
		mdirwidget:set_markup(mdir_str())
	end
end

local function imap_sync()
	if imap_running or not imap_enabled then
		return
	end
	if net_ifaces["wlp3s0"] == false and net_ifaces["enp0s25"] == false then
		return
	end
	imap_running = true
	mdirwidget:set_markup(" mbsync ")
	awful.spawn.with_shell("mbsync -a -q && notmuch new --quiet; awesome-client 'imap_running = false; mdir_update()'")
end

local function flip_imap()
	imap_enabled = not imap_enabled
	if imap_enabled then
		imap_sync()
	else
		mdirwidget:set_markup(" -off- ")
	end
end

gears.timer.start_new(60, function() imap_sync(); return true; end)
gears.timer.start_new(3, function() mdir_update(); return true; end)

mdir_update()

local function ellipsize(str, l)
	if string.len(str) <= l + 1 then
		return str
	end
	return string.format("%s…", str:sub(1, l))
end

mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd, function(widget, args)
	if args["{state}"] == "Stop" then
		return ' - MPD - '
	end
	return ellipsize(args["{Title}"], 24).." - "..ellipsize(args["{Album}"], 20)
end, 5)

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)

	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

	s.promptbox = awful.widget.prompt()
	s.layoutbox = awful.widget.layoutbox(s)
	s.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all)

	s.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

	s.topwibox = awful.wibar({ position = "top", screen = s })
	s.topwibox:setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			s.taglist,
			s.promptbox,
		},
		s.tasklist,
		{
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			textclock,
			s.layoutbox,
		},
	}

	s.botwibox = awful.wibar({ position = "bottom", screen = s })
	s.botwibox:setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			sep,
			cpuwidget,
			sep,
			batwidget,
			sep,
			blwidget,
			sep,
			volwidget,
			sep,
			memwidget,
			sep,
			iowidget,
			sep,
			netwidget,
			sep,
			mdirwidget,
		},
		sep,
		{
			layout = wibox.layout.fixed.horizontal,
			mpdwidget,
			sep,
		},
	}
end)

globalkeys = awful.util.table.join(
	awful.key({ modkey, }, "Left", awful.tag.viewprev, {group = "tag"}),
	awful.key({ modkey, }, "Right", awful.tag.viewnext, {group = "tag"}),
	awful.key({ modkey, }, "Escape", awful.tag.history.restore, {group = "tag"}),

	awful.key({ modkey, }, "j",
		function() awful.client.focus.byidx( 1) end, {group = "client"}),
	awful.key({ modkey, }, "k",
		function() awful.client.focus.byidx(-1) end, {group = "client"}),

	awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx( 1) end,
		{group = "client"}),
	awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
		{group = "client"}),
	awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative( 1) end,
		{group = "screen"}),
	awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
		{group = "screen"}),
	awful.key({ modkey, }, "u", awful.client.urgent.jumpto, {group = "client"}),
	awful.key({ modkey, }, "Tab", function()
			awful.client.focus.history.previous()
			if client.focus then client.focus:raise() end
		end, {group = "client"}),

	awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart, {group = "awesome"}),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, {group = "awesome"}),

	awful.key({ modkey, }, "l", function() awful.tag.incmwfact( 0.05) end,
		{group = "layout"}),
	awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
		{group = "layout"}),
	awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster( 1, nil, true) end,
		{group = "layout"}),
	awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
		{group = "layout"}),
	awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol( 1, nil, true) end,
		{group = "layout"}),
	awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
		{group = "layout"}),
	awful.key({ modkey, }, "space", function() awful.layout.inc( 1) end,
		{group = "layout"}),
	awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
		{group = "layout"}),

	awful.key({ modkey, "Control" }, "n",
		function()
			local c = awful.client.restore()
			if c then
				client.focus = c
				c:raise()
			end
		end, {group = "client"}),

	awful.key({ modkey, altkey }, "i", function() awful.spawn("chromium") end),
	awful.key({ modkey, altkey }, ".", function() awful.spawn.with_shell("mpc next; awesome-client 'vicious.force({mpdwidget})'") end),
	awful.key({ modkey, altkey }, ",", function() awful.spawn.with_shell("mpc prev; awesome-client 'vicious.force({mpdwidget})'") end),
	awful.key({ modkey, altkey }, "-", function() awful.spawn("mpc toggle") end),
	awful.key({ modkey, altkey }, "/", function() awful.spawn("mpc toggle") end),
	awful.key({ modkey, altkey }, "Up", function() awful.spawn("slock") end),
	awful.key({ modkey, altkey }, "1", function() awful.spawn("setxkbmap us altgr-intl -option caps:none") end),
	awful.key({ modkey, altkey }, "2", function() awful.spawn("setxkbmap es cat -option caps:none") end),
	awful.key({ modkey, altkey }, "h", function() awful.spawn(terminal .. " -c ssh -e ssh shark.mvdan.cc -t TERM=screen-256color tmux -u a") end),
	awful.key({ modkey, altkey }, "j", function() awful.spawn(terminal .. " -c mutt -e mutt") end),
	awful.key({ modkey, altkey }, "k", function() awful.spawn(terminal .. " -c ranger -e ranger") end),
	awful.key({ modkey, altkey }, "n", function() awful.spawn(terminal .. " -c ncmpc -e ncmpc -f .config/ncmpc/config") end),
	awful.key({ modkey, altkey }, "e", function() awful.spawn(terminal .. " -e nvim TODO.txt") end),

	awful.key({ modkey, altkey }, "Down",  volume_mute),
	awful.key({ modkey, altkey }, "Left",  function() volume_inc(false) end),
	awful.key({ modkey, altkey }, "Right", function() volume_inc(true) end),

	awful.key({ modkey, altkey }, "Prior", function() backlight_inc(false) end),
	awful.key({ modkey, altkey }, "Next", function() backlight_inc(true) end),

	awful.key({ modkey, altkey }, "m", imap_sync),
	awful.key({ modkey, "Shift" }, "m", flip_imap),

	awful.key({ modkey }, "s", function() awful.spawn.with_shell("maim -s $(date +%F-%T).png") end),
	awful.key({ modkey }, "i", function()
		local f = io.popen("timeout 1 ip route")
		local t = f:read("*a"):sub(0, -2)
		f:close()
		naughty.notify({
			title = " % ip route",
			text = t,
			position = "bottom_right"
		})
	end),

	awful.key({ modkey }, "r", function() awful.screen.focused().promptbox:run() end),

	awful.key({ modkey }, "x",
		function() awful.prompt.run {
			prompt       = "Run Lua code: ",
			textbox      = awful.screen.focused().promptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval"
		} end, {group = "awesome"}),

	awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey, }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, {group = "client"}),
	awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
		{group = "client"}),
	awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
		{group = "client"}),
	awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
		{group = "client"}),
	awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
		{group = "client"}),
	awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
		{group = "client"}),
	awful.key({ modkey, }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, {group = "client"})
)

for i = 1, 10 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end),
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end),
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end)
	)
end

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

awful.rules.rules = {
	{ rule = { }, properties = {
		border_width = beautiful.border_width,
		border_color = beautiful.border_normal,
		focus = awful.client.focus.filter,
		raise = true,
		keys = clientkeys,
		buttons = clientbuttons,
		screen = awful.screen.preferred,
		placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		size_hints_honor = false,
		},
	},

	{ rule_any = {
		instance = {
		},
		class = {
			"pinentry",
			"xtightvncviewer",
		},
		name = {
			"Event Tester", -- xev
		},
		role = {
			"pop-up",
		},
	}, properties = { floating = true }},
	{ rule = { class = "ssh" }, properties = { tag = "2" } },
	{ rule = { class = "mutt" }, properties = { tag = "3" } },
	{ rule = { class = "Telegram" }, properties = { tag = "7" } },
	{ rule = { class = "Chromium" }, properties = { tag = "8" } },
	{ rule = { class = "ranger" }, properties = { tag = "9" } },
	{ rule = { class = "ncmpc" }, properties = { tag = "0" } },
}

client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position
		and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
