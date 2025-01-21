return {
	"nvim-telescope/telescope.nvim",

	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{

			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },

		-- Show emojis
		{ "nvim-telescope/telescope-symbols.nvim" },

		-- Useful for getting pretty icons, but requires a Nerd Font.
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		local actions = require("telescope.actions")
		local layout_actions = require("telescope.actions.layout")

		require("telescope").setup({
			defaults = {
				path_display = { "truncate" },
				wrap_results = true,
				layout_strategy = "vertical",
				cycle_layout_list = { "horizontal", "bottom_pane", "vertical" },
				mappings = {
					i = {
						-- replace default qflist actions
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,

						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,

						["<C-n>"] = actions.cycle_history_next,
						["<C-p>"] = actions.cycle_history_prev,

						["<A-l>"] = layout_actions.cycle_layout_next,
						["<C-l>"] = layout_actions.cycle_layout_prev,
						["<A-p>"] = layout_actions.toggle_preview,
						["<A-c>"] = layout_actions.toggle_prompt_position,
						["<A-m>"] = layout_actions.toggle_mirror,
						["<C-x>"] = actions.delete_buffer,
					},

					n = {
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
					},
				},
			},
			preview = false,
			pickers = {},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		local extensions = {
			-- "danielws",
			"elixir_dev",
			"notify",
			"luasnip",
			"fzf",
			"ui-select",
			"yank_history",
		}

		for _, extension in ipairs(extensions) do
			local extension_load, _ = pcall(require("telescope").load_extension, extension)

			if not extension_load then
				vim.notify("Failed to load Telescope extension: " .. extension, vim.log.levels.ERROR)
			end
		end
	end,
}
