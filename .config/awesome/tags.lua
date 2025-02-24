local awful = require("awful")

local tags = {
	-- Define tags for each screen
	names = { "", "Web", "3", "4", "5", "6", "7", "8", "9" },
	layout = {
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
		awful.layout.suit.tile,
	},
}

local function setup_tags()
	-- Iterate over each screen and set tags
	awful.screen.connect_for_each_screen(function(s)
		awful.tag(tags.names, s, tags.layout)
	end)
end

return {
	setup_tags = setup_tags,
	tags = tags,
}
