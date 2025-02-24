-- Bluetooth Devices Widget for AwesomeWM

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

------------------------------------------
-- Helper functions
------------------------------------------

local function get_bluetooth_devices()
	local devices = {}
	local cmd = "bluetoothctl devices Connected"
	local handle = io.popen(cmd)
	if handle then
		for line in handle:lines() do
			local mac, name = line:match("Device (%S+) (.+)")
			if mac and name then
				table.insert(devices, { mac = mac, name = name })
			end
		end
		handle:close()
	end
	return devices
end

local function get_battery_percentage(mac)
	local cmd = "upower -i /org/bluez/hci0/dev_" .. mac:gsub(":", "_") .. " | grep percentage | awk '{print $2}'"
	local handle = io.popen(cmd)
	local battery = handle:read("*l")
	handle:close()
	return battery
end

local function format_devices(devices)
	local formatted = ""
	for _, device in ipairs(devices) do
		local battery = get_battery_percentage(device.mac)
		local battery_text = battery and " (Battery: " .. battery .. ")" or ""
		formatted = formatted .. "• " .. device.name .. battery_text .. "\n"
	end
	return formatted
end

------------------------------------------
-- Bluetooth widget interface
------------------------------------------

local bluetooth_widget = {}
function bluetooth_widget:new(args)
	local obj = setmetatable({}, { __index = self })
	obj:init(args)
	return obj
end

function bluetooth_widget:init(args)
	self.widget = wibox.widget.textbox()
	self.widget.font = beautiful.font or "Monospace 10" -- Use theme font
	self.tooltip = awful.tooltip({ objects = { self.widget } })

	self.timer = gears.timer({ timeout = args.timeout or 15 })
	self.timer:connect_signal("timeout", function()
		self:update()
	end)
	self.timer:start()
	self:update()
end

function bluetooth_widget:update()
	local devices = get_bluetooth_devices()

	if #devices == 0 then
		self.widget:set_text("No connected devices")
		self.tooltip:set_text("No Bluetooth devices connected.")
	else
		local formatted = format_devices(devices)
		self.widget:set_markup(": " .. #devices .. " connected")
		self.tooltip:set_markup(formatted)
	end
end

return setmetatable(bluetooth_widget, {
	__call = bluetooth_widget.new,
})
