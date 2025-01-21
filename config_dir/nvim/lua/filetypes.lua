local M = {}

function M.add_file_types()
	vim.filetype.add({
		extension = {
			ex = "elixir",
			exs = "elixir",
			tf = "terraform",
		},
		-- filename = {
		--   ["MyCustomFile"] = "lua",
		-- },
		-- pattern = {
		--   ["%.special%.txt"] = "markdown",
		-- },
	})
end

return M
