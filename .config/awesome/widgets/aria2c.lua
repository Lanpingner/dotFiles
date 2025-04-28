local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

------------------------------------------
-- Mini JSON decoder (enough for aria2c)
------------------------------------------
local function simple_json_decode(str)
	local ok, result = pcall(function()
		return load("return " .. str:gsub('"%s*:%s*', '"='):gsub('"%s*,%s*', '",'))()
	end)
	if ok then
		return result
	else
		return nil
	end
end

------------------------------------------
-- Helper functions
------------------------------------------

local function aria2c_status()
	local cmd =
		[[curl -s -d '{"jsonrpc":"2.0","id":"qwer","method":"aria2.tellActive","params":[]}' http://localhost:6800/jsonrpc]]
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	-- fix for curl returning empty
	if not result or result == "" then
		return nil
	end

	local data = simple_json_decode(result)
	if not data or not data.result then
		return {}
	end

	return data.result
end

local function format_downloads(downloads)
	if #downloads == 0 then
		return "No active downloads"
	end

	local formatted = ""
	for _, dl in ipairs(downloads) do
		local name = dl.bittorrent and dl.bittorrent.info.name
			or (dl.files and dl.files[1] and dl.files[1].path:match("([^/\\]+)$") or "Unknown")
		local total = tonumber(dl.totalLength) or 0
		local completed = tonumber(dl.completedLength) or 0
		local progress = total > 0 and math.floor((completed / total) * 100) or 0

		formatted = formatted .. string.format("%s (%d%%)\n", name, progress)
	end

	return formatted
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
	self.widget.font = beautiful.font or "Monospace 10" -- Use theme font
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
