-- awesome >= 3.5.1
-- vicious >= 2.1.1

local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
naughty = require("naughty")
local menubar = require("menubar")
vicious = require("vicious")
require("gears.wallpaper").set(require("gears.color")("#000000"))

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Oops, an error happened!",
						 text = err })
		in_error = false
	end)
end

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

terminal = "urxvtc"
exec = awful.util.spawn
sexec = awful.util.spawn_with_shell
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
local maildirs = {
	dan = {
		"/home/mvdan/Mail/linode/INBOX",
		"/home/mvdan/Mail/linode/Univ",
		"/home/mvdan/Mail/linode/FDroid"
	},
	mls = {
		"/home/mvdan/Mail/linode/Creu",
		"/home/mvdan/Mail/linode/Fsfe",
		"/home/mvdan/Mail/linode/GLcat",
		"/home/mvdan/Mail/linode/Cau",
		"/home/mvdan/Mail/linode/Debian"
	}
}

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
taglist.buttons = awful.util.table.join(
				  awful.button({ }, 1, awful.tag.viewonly),
				  awful.button({ modkey }, 1, awful.client.movetotag),
				  awful.button({ }, 3, awful.tag.viewtoggle),
				  awful.button({ modkey }, 3, awful.client.toggletag))
tasklist = {}

p_grey = "#555"
p_green = "#4c4"
p_red = "#c44"
p_blue = "#66e"
p_yellow = "#bb4"

local sep = wibox.widget.textbox()
sep:set_text("   ")

cpus_count = 0
for line in io.lines("/proc/stat") do
	if string.match(line,"^cpu[%d]+") then cpus_count = cpus_count + 1 end
end

cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
	local cpucontent=""
	for cn=1,cpus_count,1 do
		cpucontent = cpucontent..string.format("%4s", args[cn])
	end
	return cpucontent
end,1)

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
	if args[1] == "-" then
		return string.format("%3s",args[2])..string.format("%6s",args[3])
	elseif args[1] == '+' then
		return "<span color='"..p_green.."'>"..string.format("%3s",args[2]).."</span>"..string.format("%6s",args[3])
	else
		return "<span color='"..p_green.."'>"..string.format("%3s",args[2]).."</span> 00:00"
	end
end, 2, "BAT1")

volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, function(widget, args)
	if args[2] == "♫" then return string.format("%3s",args[1])
	else return '<span color="'..p_blue..'">'..string.format("%3s",args[1])..'</span>' end
end, 2, "Master")

memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem,
function (widget, args)
	local used = "<span color='"..p_yellow.."'>"..string.format("%5s",args[2]).."</span>"
	local nonfree = "<span color='"..p_blue.."'>"..string.format("%4s",args[9]).."</span>"
	local total = "<span color='"..p_green.."'>"..string.format("%-5s",args[3]).."</span>"
	return used..' '..nonfree..' '..total
end,1)

local devices

function add_dev(dev)
	for i,dev_ in ipairs(devices) do
		if dev == dev_ then
			return
		end
	end
	table.insert(devices,dev)
end

iowidget = wibox.widget.textbox()
vicious.register(iowidget, vicious.widgets.dio,
function (widget, args)
	local iocontent = ""
	devices = { 'a' }
	for line in io.lines("/proc/mounts") do
		if line:sub(1,7) == "/dev/sd" then
			add_dev(line:sub(8,8))
		end
	end
	for i,dev in ipairs(devices) do
		dev = "sd"..dev
		local write = '<span color="'..p_yellow..'">'..string.format("%5s",args["{"..dev.." write_mb}"])..'</span>'
		local read = '<span color="'..p_green..'">'..string.format("%-5s",args["{"..dev.." read_mb}"])..'</span>'
		if iocontent == "" then iocontent = write..' '..dev..' '..read
		else iocontent = iocontent..'  '..write..' '..dev..' '..read end
	end
	return iocontent
end,1)

function wlan0_n()
	local name = io.popen("wpa_cli status wlan0 | sed -n 's/^id_str=//p'"):read("*l")
	if name ~= nil then return name else return "??" end
end

function wlan0_q()
	for line in io.lines("/proc/net/wireless") do
		if line:sub(2,6) == 'wlan0' then
			return string.match(line, "([%d]+)[.]")
		end
	end
	return "??"
end

netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
	local netcontent = ""
	net_ifaces = { eth0 = false, wlan0 = false, usb0 = false}
	for dev,enabled in pairs(net_ifaces) do
		local rx = args['{'..dev..' rx_mb}']
		if dev == 'wlan0' or (rx ~= '0.0' and rx ~= nil) then
			net_ifaces[dev] = true
			local text = ''
			local rx = rx
			local up = string.format("%5s",args['{'..dev..' up_kb}'])
			local tx = args['{'..dev..' tx_mb}']
			local dn = string.format("%-6s",args['{'..dev..' down_kb}'])
			if dev == 'wlan0' then
				text = '<span foreground="'..p_yellow..'">'..up..'</span> '..tx..' '..wlan0_n()..' '..wlan0_q()..' '..rx..' <span foreground="'..p_green..'">'..dn..'</span>'
			else
				text = '<span foreground="'..p_yellow..'">'..up..'</span> '..tx..' '..rx..' <span foreground="'..p_green..'">'..dn..'</span>'
			end
			netcontent = netcontent..text
		end
	end
	return netcontent
	end,1)

local imap_enabled = true

mdirwidget = wibox.widget.textbox()
function mdirwidget_update()
	local mdircontent = ""
	for name,paths in pairs(maildirs) do
		local count = 0
		for n,path in ipairs(paths) do
			count = count + io.popen("find '"..path.."/new' -type f | wc -l"):read("*n")
		end
		if not imap_enabled then name = "<span foreground='"..p_grey.."'>"..name.."</span>" end
		if count > 0 then
			mdircontent = mdircontent..name.." <span foreground='"..p_green.."'>"..string.format("%-3d",count).."</span>"
		else
			mdircontent = mdircontent..name.." "..string.format("%-3d",count)
		end
	end
	mdirwidget:set_markup(mdircontent)
end

local imap_running = false

function offlineimap_run(force)
	if not imap_enabled then
		return 0
	end
	if not force and (net_ifaces["wlan0"] == false and net_ifaces["eth0"] == false) then
		imap_enabled = false
		return -1
	end
	imap_running = true
	sexec('offlineimap &>/dev/null; notmuch new &>/dev/null; echo \\"mdirwidget_update()\\" | awesome-client')
	imap_running = false
end

function offlineimap_toggle()
	imap_enabled = not imap_enabled
	mdirwidget_update()
	if imap_enabled then
		offlineimap_run()
	end
end

imap = timer({ timeout = 120 })
imap:connect_signal("timeout", offlineimap_run)
imap:start()

mdirtimer = timer({ timeout = 10 })
mdirtimer:connect_signal("timeout", function() 
	if not imap_running then mdirwidget_update() end
end)
mdirtimer:start()

mdirwidget_update()

mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd,
function (widget, args)
   if args["{state}"] == "Stop" then return '  - MPD -  '
   else return args["{Title}"]..' - '..args['{Album}'] end
end,2)

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

globalkeys = awful.util.table.join(
	awful.key({ modkey,		   }, "Left",   awful.tag.viewprev	   ),
	awful.key({ modkey,		   }, "Right",  awful.tag.viewnext	   ),
	awful.key({ modkey,		   }, "Escape", awful.tag.history.restore),

	awful.key({ modkey,		   }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey,		   }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),

	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)	end),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)	end),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,		   }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,		   }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),

	awful.key({ modkey,		   }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),

	awful.key({ modkey,		   }, "l",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ modkey,		   }, "h",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ modkey, "Shift"   }, "h",	 function () awful.tag.incnmaster( 1)	  end),
	awful.key({ modkey, "Shift"   }, "l",	 function () awful.tag.incnmaster(-1)	  end),
	awful.key({ modkey, "Control" }, "h",	 function () awful.tag.incncol( 1)		 end),
	awful.key({ modkey, "Control" }, "l",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ modkey,		   }, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" }, "n", awful.client.restore),

	awful.key({ }, "#121", function () sexec("amixer -q set Master toggle ; echo \'vicious.force({volwidget})\' | awesome-client") end),
	awful.key({ }, "#122", function () sexec("amixer -M -q set Master 5%- ; echo \'vicious.force({volwidget})\' | awesome-client") end),
	awful.key({ }, "#123", function () sexec("amixer -M -q set Master 5%+ ; echo \'vicious.force({volwidget})\' | awesome-client") end),
	awful.key({ }, "#150", function () sexec("xset dpms force off") end),

	awful.key({ modkey, altkey}, "t", function () sexec("~/.misc/xrandr-iter") end),
	
	awful.key({ modkey, altkey}, "f", function () sexec(terminal .. " -name weechat -e weechat-curses") end),
	awful.key({ modkey, altkey}, "g", function () sexec(terminal .. " -name ssh_confine -e ssh dev1 -t TERM=screen-256color tmux -u a") end),
	awful.key({ modkey, altkey}, "h", function () sexec(terminal .. " -name ssh_mvdan -e ssh linode -t TERM=screen-256color tmux -u a") end),
	awful.key({ modkey, altkey}, "j", function () sexec(terminal .. " -name mutt -e sh -c \"export TERM=screen-256color && mutt\"") end),
	awful.key({ modkey, altkey}, "e", function () sexec(terminal .. " -name todo -e vim ~/todo") end),
	awful.key({ modkey, altkey}, "b", function () sexec(terminal .. " -name newsbeuter -e sh -c newsbeuter") end),
	awful.key({ modkey, altkey}, "k", function () sexec(terminal .. " -name ranger -e ranger") end),
	awful.key({ modkey, altkey}, "m", function () sexec(terminal .. " -name rtorrent -e rtorrent") end),
	awful.key({ modkey, altkey}, "n", function () sexec(terminal .. " -name ncmpcpp -e ncmpcpp") end),

	awful.key({ modkey, altkey}, "i", function () sexec("chromium") end),

	awful.key({ }, "#171", function () sexec("ncmpcpp next; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
	awful.key({ }, "#172", function () sexec("ncmpcpp toggle; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
	awful.key({ }, "#173", function () sexec("ncmpcpp prev; echo \'vicious.force({mpdwidget})\' | awesome-client") end),
	awful.key({ }, "#174", function () sexec("ncmpcpp stop; echo \'vicious.force({mpdwidget})\' | awesome-client") end),

	awful.key({ modkey }, "i", function ()
		naughty.notify({
			title = " % ip route",
			text = io.popen("ip route"):read("*a"):sub(0,-2),
			position = "bottom_right"
		})
	end),
	
	awful.key({ modkey, altkey}, "o", function () offlineimap_run(true) end),
	awful.key({ modkey, altkey, "Shift" }, "o", function () offlineimap_toggle() end),
	
	awful.key({ modkey, altkey}, "y", function () sexec("eject -T") end),

	awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end),

	awful.key({ modkey, "Shift" }, "o", function () sexec("dwb") end),
	awful.key({ modkey }, "o", function ()
		awful.prompt.run({ prompt = "dwb: " },
		promptbox[mouse.screen].widget,
		function (c)
			sexec("dwb "..c:gsub("\\", "\\\\"):gsub(" ", '\\ '):gsub("'", "\\'"):gsub('"', '\\"'), false)
		end)
	end),

	awful.key({ modkey }, "u", function ()
		awful.prompt.run({ prompt = "mailman: " },
		promptbox[mouse.screen].widget,
		function (c)
			sexec("/bin/sh -c 'cd ~/fsfe/internal/Howto && BROWSER=dwb ./ML.sh "..c.."'", false)
		end)
	end),
	
	awful.key({ modkey, "Shift" }, "p", function ()
		awful.prompt.run({ prompt = "pkill: " },
		promptbox[mouse.screen].widget,
		function (c)
			sexec("pkill --signal SIGKILL'"..c.."'", false)
		end)
	end),

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
	awful.key({ modkey,		   }, "f",	  function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",	  function (c) c:kill()						 end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle					 ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,		   }, "o",	  awful.client.movetoscreen						),
	awful.key({ modkey,		   }, "t",	  function (c) c.ontop = not c.ontop			end),
	awful.key({ modkey,		   }, "n",
		function (c)
			c.minimized = true
		end),
	awful.key({ modkey,		   }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end)
)

for i = 1, 10 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 9,
				  function ()
						local tag = awful.tag.gettags(mouse.screen)[i]
						if tag then
						   awful.tag.viewonly(tag)
						end
				  end),
		awful.key({ modkey, "Control" }, "#" .. i + 9,
				  function ()
					  local tag = awful.tag.gettags(mouse.screen)[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end),
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
				  function ()
					  local tag = awful.tag.gettags(client.focus.screen)[i]
					  if client.focus and tag then
						  awful.client.movetotag(tag)
					 end
				  end),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
				  function ()
					  local tag = awful.tag.gettags(client.focus.screen)[i]
					  if client.focus and tag then
						  awful.client.toggletag(tag)
					  end
				  end))
end

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

local sheight = screen[1].geometry.height
local swidth = screen[1].geometry.width

awful.rules.rules = {
	{ rule = { },
	  properties = { border_width = beautiful.border_width,
		  border_color = beautiful.border_normal,
		  focus = awful.client.focus.filter,
		  size_hints_honor = false,
		  keys = clientkeys,
		  buttons = clientbuttons } },
	{ rule = { class = "MPlayer" },
	  properties = { floating = true } },
	{ rule = { class = "pinentry" },
	  properties = { floating = true } },
	{ rule = { class = "Gimp" },
	  properties = { floating = true, y = 21, height = sheight-42 } },
	{ rule = { class = "Gimp", role = "gimp-toolbox" },
		properties = { x = 0, width = 225 }, },
	{ rule = { class = "Gimp", role = "gimp-image-window" },
		properties = { x = 225, width = swidth-450 }, },
	{ rule = { class = "Gimp", role = "gimp-dock" },
		properties = { x = swidth-225, width = 225 }, },
	{ rule = { instance = "ssh_mvdan" },
	  properties = { tag = tags[1][2] } },
	{ rule = { instance = "weechat" },
	  properties = { tag = tags[1][3] } },
	{ rule = { instance = "ssh_confine" },
	  properties = { tag = tags[1][4] } },
	{ rule = { instance = "mutt" },
	  properties = { tag = tags[1][3] } },
	{ rule = { instance = "newsbeuter" },
	  properties = { tag = tags[1][5] } },
	{ rule = { class = "Dwb" },
	  properties = { tag = tags[1][7] } },
	{ rule = { class = "Chromium" },
	  properties = { tag = tags[1][8] } },
	{ rule = { instance = "ranger" },
	  properties = { tag = tags[1][9] } },
	{ rule = { instance = "rtorrent" },
	  properties = { tag = tags[1][10] } },
	{ rule = { instance = "ncmpcpp" },
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
