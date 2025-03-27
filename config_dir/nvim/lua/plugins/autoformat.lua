return {
	"stevearc/conform.nvim",
	-- dev = true,
	lazy = false,
	opts = {
		-- log_level = vim.log.levels.DEBUG,
		notify_on_error = true,
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			local disabled_languages = { c = true, cpp = true }

			return {
				timeout_ms = 2000,
				lsp_format = disabled_languages[vim.bo[bufnr].filetype] and "never" or "fallback",
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettier", lsp_format = "fallback" },
			typescriptreact = { "prettier", lsp_format = "fallback" },
			typescript = { "prettier", lsp_format = "fallback" },
			elixir = { "custom_mix", lsp_format = "fallback" },
			-- elixir = { "mix", lsp_format = "fallback" },
			sql = { "pg_format" },
		},
		formatters = {
			custom_mix = {
				command = "mix",
				args = { "format", "$FILENAME" },
				-- Disabled the stdin because of noise
				-- args = { "format", "--stdin-filename", "$FILENAME", "-" },
				stdin = false,
				cwd = function(_self, ctx)
					return vim.fs.root(ctx.dirname, { "mix.exs" })
				end,
			},
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

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting just for this buffer
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
	end,
}
