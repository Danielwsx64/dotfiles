return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
	},
	init = function()
		require("keymaping").register()
	end,
}
