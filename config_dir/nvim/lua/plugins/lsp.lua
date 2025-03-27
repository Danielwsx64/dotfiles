return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ "j-hui/fidget.nvim", opts = {} },

		-- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local default_capabilities = vim.lsp.protocol.make_client_capabilities()
		default_capabilities.textDocument.semanticTokens = vim.NIL
		default_capabilities.workspace.semanticTokens = vim.NIL

		local servers = {
			arduino_language_server = {
				capabilities = default_capabilities,
				cmd = {
					"arduino-language-server",
					"-clangd",
					"/usr/bin/clangd",
					"-cli",
					"/home/daniel/.bin/arduino-cli",
					"-cli-config",
					"/home/daniel/.arduino15/arduino-cli.yaml",
					"-fqbn",
					"arduino:avr:nano",
				},
			},
			clangd = {},
			pylsp = {},
			tailwindcss = {},
			taplo = {},
			dockerls = {},
			cssls = {},
			terraformls = {},
			elixirls = {},
			html = {},
			jsonls = {},
			rust_analyzer = {},
			ts_ls = {},
			vimls = {},
			lua_ls = {
				settings = {
					Lua = {
						-- Tells Lua that a global variable named vim exists to not have warnings when configuring neovim
						diagnostics = { globals = { "vim", "it", "describe" } },
						completion = { callSnippet = "Replace" },
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			},
		}

		require("diagnostic").configure()

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)

				require("keymaping").register_lsp_keys(client, event.buf)
			end,
		})

		-- Autocommand to set FQBN based on project or file
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = { "*.ino" },
			callback = function(_args)
				local filename = vim.fn.expand("%:t")
				local sufix = filename:match("%.([%w]+%.ino)$")

				local board_mappings = {
					["mega.ino"] = "arduino:avr:mega",
					["uno.ino"] = "arduino:avr:uno",
					default = "arduino:avr:uno",
				}

				local fqbn = board_mappings[sufix] or board_mappings.default

				require("lspconfig").arduino_language_server.setup({
					capabilities = servers.arduino_language_server.capabilities,
					cmd = {
						"arduino-language-server",
						"-clangd",
						"/usr/bin/clangd",
						"-cli",
						"/home/daniel/.bin/arduino-cli",
						"-cli-config",
						"/home/daniel/.arduino15/arduino-cli.yaml",
						"-fqbn",
						fqbn,
					},
				})
			end,
		})

		require("mason").setup()

		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		local ensure_installed = vim.tbl_keys(servers or {})

		require("mason-lspconfig").setup({
			ensure_installed = ensure_installed,
			automatic_installation = true,
			handlers = {
				function(server_name)
					local server_config = servers[server_name] or {}
					require("lspconfig")[server_name].setup(server_config)
				end,
			},
		})
	end,
}
