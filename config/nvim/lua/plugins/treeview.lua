return {
	"kyazdani42/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		on_attach = require("keymaping").register_tree_keys,
		view = { width = 35, number = true, relativenumber = true },
	},
}
