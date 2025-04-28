-- Network Interfaces Widget for AwesomeWM

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

------------------------------------------
-- Helper functions
------------------------------------------

local function get_ip_addresses()
	local interfaces = {}
	local cmd = "ip -4 -o addr show up"
	local handle = io.popen(cmd)
	if handle then
		for line in handle:lines() do
			local interface, ip = line:match("(%S+)%s+inet%s+(%S+)")
			if interface and ip then
				table.insert(interfaces, { interface = interface, ip = ip })
			end
		end
		handle:close()
	end
	return interfaces
end

local function get_default_interface()
	local cmd = "ip route | grep '^default' | awk '{print $5}'"
	local handle = io.popen(cmd)
	local default_iface = handle:read("*l")
	handle:close()
	return default_iface
end

local function get_ssid(interface)
	local cmd = "iw dev " .. interface .. " link | grep 'SSID' | awk '{print $2}'"
	local handle = io.popen(cmd)
	local ssid = handle:read("*l")
	handle:close()
	return ssid
end

local function color_text(text, color)
	return '<span color="' .. color .. '">' .. text .. "</span>"
end

local function format_interfaces(interfaces, default_iface)
	local formatted = ""
	for _, iface in ipairs(interfaces) do
		local prefix = iface.interface == default_iface and "* " or "  "
		local color = iface.interface == default_iface and "green" or "white"
		local ssid = (iface.interface == default_iface and iface.interface ~= nil) and get_ssid(iface.interface) or nil
		local ssid_text = ssid and " (" .. ssid .. ")" or ""
		formatted = formatted .. prefix .. color_text(iface.interface .. ": " .. iface.ip .. ssid_text, color) .. "\n"
	end
	return formatted
end

------------------------------------------
-- Network widget interface
------------------------------------------

local network_widget = {}
function network_widget:new(args)
	local obj = setmetatable({}, { __index = self })
	obj:init(args)
	return obj
end

function network_widget:init(args)
	self.widget = wibox.widget.textbox()
	self.widget.font = beautiful.font or "Monospace 10" -- Use theme font
	self.tooltip = awful.tooltip({ objects = { self.widget } })

	self.timer = gears.timer({ timeout = args.timeout or 10 })
	self.timer:connect_signal("timeout", function()
		self:update()
	end)
	self.timer:start()
	self:update()
end

function network_widget:update()
	local interfaces = get_ip_addresses()
	local default_iface = get_default_interface() or ""

	if #interfaces == 0 or default_iface == "" then
		self.widget:set_text("No active interfaces")
		self.tooltip:set_text("No active network interfaces found.")
	else
		local formatted = format_interfaces(interfaces, default_iface)
		local default_ip = "N/A"
		for _, iface in ipairs(interfaces) do
			if iface.interface == default_iface then
				default_ip = iface.ip
				break
			end
		end
		local label_iface = default_iface ~= "" and default_iface or "?"
		self.widget:set_markup(": " .. color_text(label_iface .. " (" .. default_ip .. ")", "green"))
		self.tooltip:set_markup(formatted)
	end
end

return setmetatable(network_widget, {
	__call = network_widget.new,
})
