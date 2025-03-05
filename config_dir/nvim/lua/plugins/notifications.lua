return {
	"rcarriga/nvim-notify",
	config = function()
		vim.notify = require("notify")

		require("notify").setup({
			background_colour = "#1e2030",
			fps = 60,
			icons = {
				DEBUG = "",
				ERROR = "",
				INFO = "",
				TRACE = "✎",
				WARN = "",
			},
			level = 2,
			minimum_width = 50,
			render = "wrapped-compact",
			stages = "fade_in_slide_out",
			time_formats = {
				notification = "%T",
				notification_history = "%FT%T",
			},
			timeout = 3000,
			top_down = true,
		})
	end,
}
