return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = { "andymass/vim-matchup" },
	opts = {
		ensure_installed = {
			"css",
			"dockerfile",
			"elixir",
			"html",
			"javascript",
			"json",
			"lua",
			"luadoc",
			"markdown",
			"query", -- for quering
			"rust",
			"toml",
			"vim",
			"vimdoc",
		},

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = false,

		-- Autoinstall languages that are not installed
		auto_install = true,

		highlight = {
			enable = true,

			-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
			-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
			-- the name of the parser)
			-- list of language that will be disabled
			disable = {},

			-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
			--  If you are experiencing weird indenting issues, add the language to
			--  the list of additional_vim_regex_highlighting and disabled languages for indent.
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby", "python" } },
		matchup = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = require("keymaping").treesitter_incremental_selec_keys(),
		},
		refactor = {
			highlight_definitions = {
				enable = true,
				-- Set to false if you have an `updatetime` of ~100.
				clear_on_cursor_move = true,
			},
			highlight_current_scope = { enable = false },

			smart_rename = {
				enable = true,
				keymaps = require("keymaping").treesitter_refactor_keys().smart_rename,
			},
			navigation = {
				enable = true,
				keymaps = require("keymaping").treesitter_refactor_keys().navigation,
			},
		},
	},
	config = function(_, opts)
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`

		-- Prefer git instead of curl in order to improve connectivity in some environments
		require("nvim-treesitter.install").prefer_git = true
		require("nvim-treesitter.configs").setup(opts)

		-- There are additional nvim-treesitter modules that you can use to interact
		-- with nvim-treesitter. You should go explore a few and see what interests you:
		--
		--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
		--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
		--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	end,
}
