return {
	"stevearc/conform.nvim",
	lazy = false,
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disabled_languages = { c = true, cpp = true }

			return {
				timeout_ms = 2000,
				lsp_format = disabled_languages[vim.bo[bufnr].filetype] and "never" or "fallback",
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettier" },
			typescriptreact = { "prettier" },
			typescrip = { "prettier" },
			elixir = { "mix" },
			sql = { "pg_format" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use a sub-list to tell conform to run *until* a formatter
			-- is found.
			-- javascript = { { "prettierd", "prettier" } },
		},
	},
	init = function()
		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			require("conform").format({ async = true, lsp_format = "fallback", range = range })
		end, { range = true })
	end,
}
