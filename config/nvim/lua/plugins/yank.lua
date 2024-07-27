return {
	"gbprod/yanky.nvim",

	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		local utils = require("yanky.utils")
		local mapping = require("yanky.telescope.mapping")

		require("yanky").setup({
			picker = {
				telescope = {
					use_default_mappings = false,
					mappings = {
						default = mapping.put("p"),
						i = {
							["<C-p>"] = mapping.put("P"),
							["<C-x>"] = mapping.delete(),
							["<C-r>"] = mapping.set_register(utils.get_default_register()),
						},
						n = {
							p = mapping.put("p"),
							P = mapping.put("P"),
							d = mapping.delete(),
							r = mapping.set_register(utils.get_default_register()),
						},
					},
				},
			},
		})
	end,
}
