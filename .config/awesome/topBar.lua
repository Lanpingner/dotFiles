local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

local blue_wid = require("./widgets/blue")
local aria2c_widget = require("./widgets/aria2c")
local battery_widget = require("./widgets/battery")
local ip_info_widget = require("./widgets/ip_info")
--local weather = require("./widgets/weather")
local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized("/home/romeo/Pictures/background/index.jpg", s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)
	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	s.blueTooth = blue_wid({
		timeout = 15,
	})

	s.ipInfo = ip_info_widget({
		timeout = 10,
	})

	s.aria2c = aria2c_widget({
		timeout = 10,
	})

	s.battery = battery_widget({
		ac = "AC",
		adapter = "BAT0",
		ac_prefix = "AC: ",
		battery_prefix = "Bat: ",
		percent_colors = {
			{ 25, "red" },
			{ 50, "orange" },
			{ 999, "green" },
		},
		listen = true,
		timeout = 10,
		widget_text = "${AC_BAT}${color_on}${percent}%${color_off}",
		widget_font = "Deja Vu Sans Mono 16",
		tooltip_text = "Battery ${state}${time_est}\nCapacity: ${capacity_percent}%",
		alert_threshold = 5,
		alert_timeout = 0,
		alert_title = "Low battery !",
		alert_text = "${AC_BAT}${time_est}",
		alert_icon = "~/Downloads/low_battery_icon.png",
		warn_full_battery = true,
		full_battery_icon = "~/Downloads/full_battery_icon.png",
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s, height = 32 })

	s.myTextClock = wibox.widget.textclock()

	s.myKeyboardLayout = awful.widget.keyboardlayout()

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.mylayoutbox,
			mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			s.myKeyboardLayout,
			wibox.widget.systray(),
			s.blueTooth,
			s.ipInfo,
			s.aria2c,
			s.battery,
			s.myTextClock,
		},
	})
end)
