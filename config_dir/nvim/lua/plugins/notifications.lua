return {
	"rcarriga/nvim-notify",
	config = function()
		vim.notify = require("notify")

		require("notify").setup({
			level = 2,
			timeout = 3000,
			background_colour = "#1e2030",
			minimum_width = 50,
			stages = "fade_in_slide_out",
			fps = 60,
			icons = {
				DEBUG = "",
				ERROR = "",
				INFO = "",
				TRACE = "✎",
				WARN = "",
			},
			render = "wrapped-compact",
			time_formats = {
				notification = "%T",
				notification_history = "%FT%T",
			},
			top_down = false,
		})
	end,
}
