return {
	"vim-test/vim-test",
	config = function()
		vim.g["test#custom_strategies"] = {
			multiplex = function(command)
				require("multiplex.shell").run(command)
			end,
		}

		vim.g["test#strategy"] = "multiplex"
	end,
}
