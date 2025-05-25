local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local json = require("dkjson") -- use dkjson

------------------------------------------
-- Helper functions
------------------------------------------

local function simple_json_decode(str)
	local result, _, err = json.decode(str)
	if err then
		return nil
	end
	return result
end

local function fetch_otp_tokens()
	local cmd = [[curl -s http://localhost:8091/otp_list]] -- change URL if needed
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	if not result or result == "" then
		return nil
	end

	local data = simple_json_decode(result)
	if type(data) ~= "table" then
		return {}
	end

	return data
end

local function format_otp_tokens(tokens)
	if #tokens == 0 then
		return "No OTP tokens available"
	end

	local formatted = ""
	for _, t in ipairs(tokens) do
		formatted = formatted .. string.format("%s\n%s\n\n", t.name or "Unknown", t.totp_token or "N/A")
	end
	return formatted
end

------------------------------------------
-- OTP Widget
------------------------------------------

local otp_widget = {}
function otp_widget:new(args)
	local obj = setmetatable({}, { __index = self })
	obj:init(args)
	return obj
end

function otp_widget:init(args)
	self.widget = wibox.widget.textbox()
	self.widget.font = beautiful.font or "Monospace 10"
	self.tooltip = awful.tooltip({ objects = { self.widget } })

	self.timer = gears.timer({ timeout = args.timeout or 30 })
	self.timer:connect_signal("timeout", function()
		self:update()
	end)
	self.timer:start()
	self:update()
end

function otp_widget:update()
	local tokens = fetch_otp_tokens()

	if not tokens then
		self.widget:set_text(" OTP down")
		self.tooltip:set_text("Failed to fetch OTP tokens.")
	elseif #tokens == 0 then
		self.widget:set_text(" No tokens")
		self.tooltip:set_text("No OTP tokens available.")
	else
		local formatted = format_otp_tokens(tokens)
		self.widget:set_markup(" OTPs")
		self.tooltip:set_text(formatted)
	end
end

return setmetatable(otp_widget, {
	__call = otp_widget.new,
})
