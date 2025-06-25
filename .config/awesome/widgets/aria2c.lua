local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local json = require("dkjson")

------------------------------------------
-- Helper functions
------------------------------------------

local function format_eta(completed, total, speed)
	completed = tonumber(completed)
	total = tonumber(total)
	speed = tonumber(speed)
	if not completed or not total or not speed or speed == 0 then
		return "∞"
	end

	local remaining = total - completed
	local seconds = math.floor(remaining / speed)
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)

	seconds = seconds % 60
	minutes = minutes % 60

	if hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	elseif minutes > 0 then
		return string.format("%dm %ds", minutes, seconds)
	else
		return string.format("%ds", seconds)
	end
end

local function aria2c_status()
	local cmd =
		[[curl -s -d '{"jsonrpc":"2.0","id":"qwer","method":"aria2.tellActive","params":[]}' http://localhost:6800/jsonrpc]]
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	if not result or result == "" then
		return nil
	end

	local data, _, err = json.decode(result)
	if not data or not data.result then
		naughty.notify({ title = "Aria2c JSON Error", text = err or "Invalid response", timeout = 5 })
		return {}
	end

	return data.result
end

local function format_downloads(downloads)
	if #downloads == 0 then
		return "No active downloads"
	end

	local lines = {}
	for _, dl in ipairs(downloads) do
		local name = "Unknown"
		if dl.bittorrent and dl.bittorrent.info and dl.bittorrent.info.name then
			name = dl.bittorrent.info.name
		elseif dl.files and dl.files[1] and dl.files[1].path then
			name = dl.files[1].path:match("([^/\\]+)$") or "Unknown"
		end

		local total = tonumber(dl.totalLength) or 0
		local completed = tonumber(dl.completedLength) or 0
		local dlspeed = tonumber(dl.downloadSpeed) or 0
		local upspeed = tonumber(dl.uploadSpeed) or 0

		local progress = total > 0 and math.floor((completed / total) * 100) or 0
		local eta = format_eta(completed, total, dlspeed)

		table.insert(
			lines,
			string.format(
				"%s\n - %d%%, ↓ %.1f KB/s, ↑ %.1f KB/s, ETA: %s",
				name,
				progress,
				dlspeed / 1024,
				upspeed / 1024,
				eta
			)
		)
	end

	return table.concat(lines, "\n\n")
end

------------------------------------------
-- Aria2c widget interface
------------------------------------------

local aria2c_widget = {}
function aria2c_widget:new(args)
	local obj = setmetatable({}, { __index = self })
	obj:init(args)
	return obj
end

function aria2c_widget:init(args)
	self.widget = wibox.widget.textbox()
	self.widget.font = beautiful.font or "Monospace 10"
	self.tooltip = awful.tooltip({ objects = { self.widget } })

	self.timer = gears.timer({ timeout = args.timeout or 10 })
	self.timer:connect_signal("timeout", function()
		self:update()
	end)
	self.timer:start()
	self:update()
end

function aria2c_widget:update()
	local downloads = aria2c_status()

	if not downloads then
		self.widget:set_text(" aria2c down")
		self.tooltip:set_text("Failed to connect to aria2c RPC server.")
	elseif #downloads == 0 then
		self.widget:set_text(" No downloads")
		self.tooltip:set_text("No active downloads")
	else
		local formatted = format_downloads(downloads)
		local active_count = #downloads
		self.widget:set_markup(" " .. active_count .. " active")
		self.tooltip:set_text(formatted)
	end
end

return setmetatable(aria2c_widget, {
	__call = aria2c_widget.new,
})
