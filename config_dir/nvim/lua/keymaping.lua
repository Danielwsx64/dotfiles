local M = {}

local function noremap(mod, lhs, rhs, desc)
	vim.keymap.set(mod, lhs, rhs, { desc = desc, silent = true })
end

local function xnoremap(mod, lhs, rhs, desc)
	vim.keymap.set(mod, lhs, rhs, { desc = desc, silent = true, expr = true })
end

local function map(mod, lhs, rhs, desc)
	vim.keymap.set(mod, lhs, rhs, { desc = desc, silent = true, remap = true })
end

function M.treesitter_refactor_keys()
	return {
		smart_rename = {
			smart_rename = "<leader>lr",
		},
		navigation = {
			goto_definition = false,
			list_definitions = false,
			list_definitions_toc = false,
			goto_next_usage = "gn",
			goto_previous_usage = "gp",
		},
	}
end

function M.luasnip_remaps(luasnip)
	noremap({ "s", "i" }, "<c-n>", function()
		if luasnip.choice_active() then
			luasnip.change_choice(1)
		end
	end, "LuaSnip next choice")

	noremap({ "s", "i" }, "<c-p>", function()
		if luasnip.choice_active() then
			luasnip.change_choice(-1)
		end
	end, "LuaSnip previous choice")
end

function M.cmp_keys(cmp, luasnip)
	local has_words_before = function()
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end

	return cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping(function()
			cmp.select_prev_item()
		end, { "i", "c" }),
		["<C-j>"] = cmp.mapping(function()
			cmp.select_next_item()
		end, { "i", "c" }),

		-- Scroll the documentation window [b]ack / [f]orward
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),

		-- Accept ([y]es) the completion.
		--  This will auto-import if your LSP supports it.
		--  This will expand snippets if the LSP sent a snippet.
		["<C-y>"] = cmp.mapping.confirm({ select = true }),

		-- If you prefer more traditional completion keymaps,
		-- you can uncomment the following lines
		["<CR>"] = cmp.mapping({
			i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
			c = function(fallback)
				if cmp.visible() then
					cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
				else
					fallback()
				end
			end,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s", "c" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s", "c" }),

		["<Esc>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.close()
			else
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, true, true), "n", true)
			end
		end, { "c" }),
	})
end

--==================
--== Treesitter Keys
--==================
function M.treesitter_incremental_selec_keys()
	return {
		init_selection = "<leader>vv",
		node_incremental = "<leader>va",
		scope_incremental = "<leader>ve",
		node_decremental = "<leader>vd",
	}
end

--================
--== LSP Keys
--================
function M.register_lsp_keys(client, bufnr)
	local telescope = require("telescope.builtin")

	local function diagnostic_goto_next()
		vim.diagnostic.jump({ count = 1 })
	end

	local function diagnostic_goto_prev()
		vim.diagnostic.jump({ count = 1 })
	end

	local leader_l_keys = {
		mode = { "n" },
		remap = false,
		nowait = false,
		buffer = bufnr,

		{ "<leader>l", group = "Code LSP / Diagnostics" },
		{ "<leader>la", vim.lsp.buf.code_action, desc = "[L]SP Code [A]ction" },
		{ "<leader>ld", vim.diagnostic.open_float, desc = "[L]ine [D]iagnostics" },
		{ "<leader>lk", vim.lsp.buf.hover, desc = "LSP symbol info" },
		{ "<leader>ln", diagnostic_goto_next, desc = "[G]oto [N]ext diagnostic line" },
		{ "<leader>lp", diagnostic_goto_prev, desc = "[G]oto [P]rev diagnostic line" },
		{ "<leader>ls", telescope.lsp_document_symbols, desc = "[L]SP Document [S]ymbols" },
	}

	if client.server_capabilities.renameProvider then
		table.insert(leader_l_keys, { "<leader>lr", vim.lsp.buf.rename, desc = "[L]SP [R]ename" })
	end

	require("which-key").add(leader_l_keys)

	require("which-key").add({
		mode = { "n" },
		remap = false,
		nowait = false,
		buffer = bufnr,

		{ "g", group = "Goto" },
		{ "gD", vim.lsp.buf.declaration, desc = "[G]oto [D]eclaration" },
		{ "gI", vim.lsp.buf.implementation, desc = "[G]oto [I]mplementation" },
		-- { "gI", telescope.lsp_implementations, desc = "[G]oto [I]mplementation" },
		{ "gd", vim.lsp.buf.definition, desc = "[G]oto [D]efinition" },
		-- { "gd", telescope.lsp_definitions, desc = "[G]oto [D]efinition" },
		{ "gh", vim.lsp.buf.hover, desc = "[G]o [H]over Documentation" },
		{ "gr", telescope.lsp_references, desc = "[G]oto [R]eferences" },
		{ "gs", vim.lsp.buf.signature_help, desc = "[G]oto [S]ignature Help" },
		{ "gT", telescope.lsp_type_definitions, desc = "[G]oto [T]ype Definition" },
	})
end

--================
--== NvimTree Keys
--================
function M.register_tree_keys(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
	vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
	vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
end

--===========================
--== Visual Multi Cursor Keys
--===========================
function M.register_multi_cursor_keys()
	vim.cmd([[ 
    let g:VM_leader                     = {'default': '<leader>m', 'visual': '<leader>m', 'buffer': '<leader>m'}
    let g:VM_theme                      = 'olive'
    let g:VM_maps                       = {}
    let g:VM_maps["Add Cursor Down"]    = '<M-n>'    " new cursor down
    let g:VM_maps["Add Cursor Up"]      = '<M-m>'    " new cursor up
    let g:VM_maps['Select All']         = '<C-a>'    " select all
    let g:VM_maps['Visual All']         = '<C-a>'
    let g:VM_maps['Start Regex Search'] = '<C-_>'
    let g:VM_maps['Surround']           = 'sa'
    let g:VM_maps['Select Operator']    = 'S'
  ]])
end

function M.register()
	local telescope = require("telescope.builtin")

	local visual_lead_binds = {
		mode = { "v" },
		remap = false, -- use `noremap` when creating keymaps
		nowait = false, -- use `nowait` when creating keymaps
		{ "<leader>?", "<CMD>WhichKey<CR>", desc = "Help" },
		{ "<leader>g", group = "Git" },
		{ "<leader>gO", '<CMD>lua require("custom_commands").open_in_browser("v")<CR>', desc = "Open in browser" },
		{ "<leader>gy", '<CMD>lua require("custom_commands").copy_link("v")<CR>', desc = "Copy repository link" },
	}

	local normal_lead_binds = {
		mode = { "n" },
		remap = false, -- use `noremap` when creating keymaps
		nowait = false, -- use `nowait` when creating keymaps

		{ "<leader>?", "<CMD>WhichKey<CR>", desc = "Help" },
		{ "<leader><ESC>", "<CMD>nohlsearch<CR>", desc = "Cancel search" },

		{ "<leader><space>", group = "Telescope finders" },
		{ "<leader><space><space>", telescope.resume, desc = "Reopen last" },
		{ "<leader><space>M", telescope.keymaps, desc = "Show keymaps" },
		{ "<leader><space>b", telescope.buffers, desc = "Buffers" },
		{ "<leader><space>c", telescope.commands, desc = "Commands" },
		{ "<leader><space>f", telescope.find_files, desc = "Files" },
		{ "<leader><space>h", telescope.command_history, desc = "Commands history" },
		{ "<leader><space>j", telescope.jumplist, desc = "Jump list" },
		{ "<leader><space>m", telescope.marks, desc = "Marks" },
		{ "<leader><space>n", "<CMD>Telescope notify<CR>", desc = "Notifications" },
		{ "<leader><space>u", "<CMD>UndotreeToggle<CR>", desc = "Toggle Undo History" },
		{ "<leader><space>y", "<CMD>Telescope yank_history<CR>", desc = "Yank History" },
		{ "<leader><space>z", telescope.builtin, desc = "Sholl all pickers" },

		{ "<leader>b", group = "Buffer" },
		{ "<leader>bD", "<CMD>%bd|e#|bd#<CR>", desc = "Delete all" },
		{ "<leader>bd", "<CMD>bd!<CR>", desc = "Delete current" },
		{ "<leader>bf", "<CMD>Format<CR>", desc = "Format" },
		{ "<leader>bl", "<c-^>", desc = "Go last" },
		{ "<leader>br", "<CMD>e!<CR>", desc = "Reload" },

		{ "<leader>e", group = "File explorer" },
		{ "<leader>ee", "<CMD>NvimTreeToggle<CR>", desc = "Open" },
		{ "<leader>ef", "<CMD>NvimTreeFindFile<CR>", desc = "Open current buffer" },
		{ "<leader>eq", "<CMD>NvimTreeClose<CR>", desc = "Close" },

		{ "<leader>f", group = "Find" },
		{ "<leader>fS", telescope.grep_string, desc = "Search word under cursor in workspace" },
		{ "<leader>fa", ":Danielws ag ", desc = "Search with ag" },
		{ "<leader>fc", "<CMD>HopCamelCase<CR>", desc = "-- HOP: Find for cammel case" },
		{ "<leader>ff", "<CMD>Telescope elixir_dev public_functions<CR>", desc = "Module public functions" },
		{ "<leader>fg", telescope.live_grep, desc = "Live Grep" },
		{ "<leader>fh", telescope.search_history, desc = "Show the search history" },
		{ "<leader>fl", "<CMD>HopLineStart<CR>", desc = "-- HOP: Find for line" },
		{ "<leader>fs", telescope.current_buffer_fuzzy_find, desc = "Current Buffer" },
		{ "<leader>fw", "<CMD>HopWord<CR>", desc = "-- HOP: Find for word" },

		{ "<leader>c", group = "Change sintax" },
		{ "<leader>cf", "<CMD>ElixirDev fn_shorthand<CR>", desc = "Elixir switch fn syntax" },
		{ "<leader>ck", "<CMD>ElixirDev switch_keys<CR>", desc = "Elixir switch map key syntax" },
		{ "<leader>cp", "<CMD>ElixirDev pipelize<CR>", desc = "Elixir turns into pipe" },

		{ "<leader>g", group = "Git" },
		{ "<leader>gB", "<CMD>lua require('gitsigns').toggle_current_line_blame()<CR>", desc = "Buffer blame" },
		{ "<leader>gD", "<CMD>lua require('gitsigns').diffthis()<CR>", desc = "Diff buffer" },
		{ "<leader>gL", "<CMD>DiffviewFileHistory<CR>", desc = "DiffView log" },
		{ "<leader>gO", '<CMD>lua require("custom_commands").open_in_browser("n")<CR>', desc = "Open in browser" },
		{ "<leader>gb", "<CMD>lua require('gitsigns').blame_line{full=true}<CR>", desc = "Blame line" },
		{ "<leader>gd", "<CMD>lua require('gitsigns').preview_hunk()<CR>", desc = "Diff hunk" },
		{ "<leader>gh", "<CMD>DiffviewFileHistory %<CR>", desc = "Buffer history" },
		{ "<leader>gl", telescope.git_commits, desc = "Log" },
		{ "<leader>gn", "<CMD>lua require('gitsigns').next_hunk()<CR>", desc = "Next hunk" },
		{ "<leader>go", "<CMD>Neogit<CR>", desc = "Open NeoGit" },
		{ "<leader>gp", "<CMD>lua require('gitsigns').prev_hunk()<CR>", desc = "Previous hunk" },
		{ "<leader>gs", telescope.git_status, desc = "Status" },
		{ "<leader>gy", '<CMD>lua require("custom_commands").copy_link("n")<CR>', desc = "Copy repository link" },

		{ "<leader>l", group = "Help" },
		{
			"<leader>hS",
			"<CMD>lua require('luasnip.loaders').edit_snippet_files()<CR>",
			desc = "Edit Snippets",
			nowait = false,
			remap = false,
		},
		{ "<leader>hh", telescope.help_tags, desc = "Open help", nowait = false, remap = false },
		{ "<leader>hs", "<CMD>Telescope luasnip<CR>", desc = "Open spnipets", nowait = false, remap = false },

		{ "<leader>l", group = "LSP commands" },
		{ "<leader>lf", telescope.diagnostics, desc = "List diagnostics" },

		{ "<leader>q", group = "Quit" },
		{ "<leader>qF", "<CMD>q!<CR>", desc = "Force" },
		{ "<leader>qX", "<CMD>xa<CR>", desc = "Quit saving" },
		{ "<leader>qa", "<CMD>qa<CR>", desc = "Quit all" },
		{ "<leader>qf", "<CMD>qa!<CR>", desc = "All force" },
		{ "<leader>qq", "<CMD>q<CR>", desc = "Quit current window" },
		{ "<leader>qx", "<CMD>x<CR>", desc = "Quit saving" },

		{ "<leader>r", group = "Run tests and shell" },
		{ "<leader>rV", "<CMD>TestVisit<CR>", desc = "Go to last test file" },
		{ "<leader>ra", "<CMD>TestSuite<CR>", desc = "Test all" },
		{ "<leader>rl", "<CMD>TestLast<CR>", desc = "Test last" },
		{ "<leader>rn", "<CMD>TestNearest<CR>", desc = "Test Nearest" },
		{ "<leader>rs", "<CMD>TestFile<CR>", desc = "Test file" },
		{ "<leader>rb", "<CMD>Multiplex run !!<CR>", desc = "Run back last terminal command" },
		{ "<leader>rv", "<CMD>Multiplex attach<CR>", desc = "Reattach tmux pane" },

		{ "<leader>s", group = "Search and Substitute" },
		{ "<leader>sn", "<CMD>Danielws better_search<CR>", desc = "Search word under cursor" },
		{ "<leader>sr", "<CMD>Danielws better_replace<CR>", desc = "Find and replace word near the cursor" },

		{ "<leader>t", group = "Tabs" },
		{ "<leader>tS", "<CMD>tabs<CR>", desc = "Show all" },
		{ "<leader>tb", "<CMD>tabm -<CR>", desc = "Move back" },
		{ "<leader>tf", "<CMD>tabm +<CR>", desc = "Move forward" },
		{ "<leader>th", "<CMD>tabp<CR>", desc = "Go left" },
		{ "<leader>tj", "<CMD>tabr<CR>", desc = "Go first" },
		{ "<leader>tk", "<CMD>tabl<CR>", desc = "Go last" },
		{ "<leader>tl", "<CMD>tabn<CR>", desc = "Go right" },
		{ "<leader>tn", "<CMD>tabnew<CR>", desc = "New" },
		{ "<leader>to", "<CMD>tabo<CR>", desc = "Close othes" },
		{ "<leader>tq", "<CMD>tabc<CR>", desc = "Close" },
		{ "<leader>ts", "<CMD>tab split<CR>", desc = "Split current buffer in a new tab" },

		{ "<leader>w", group = "Windows" },
		{ "<leader>wR", "<CMD>wincmd H<CR>", desc = "Rotate horizontal" },
		{ "<leader>wa", "<CMD>wa<CR>", desc = "Save all buffers" },
		{ "<leader>wc", "<CMD>Multiplex resize right 65 force_multiplex<CR>", desc = "Resize vim pane" },
		{ "<leader>we", "<CMD>wincmd =<CR>", desc = "All windows same size" },
		{ "<leader>wf", "<CMD>res<CR><CMD>vert res<CR>", desc = "Windows Full mode" },
		{ "<leader>wi", "<CMD>wincmd x<CR>", desc = "Invert" },

		{ "<leader>wh", "<CMD>Multiplex move left<CR>", desc = "Go left" },
		{ "<C-h>", "<CMD>Multiplex move left<CR>", desc = "Go left" },
		{ "<leader>wj", "<CMD>Multiplex move down<CR>", desc = "Go down" },
		{ "<C-j>", "<CMD>Multiplex move down<CR>", desc = "Go down" },
		{ "<leader>wk", "<CMD>Multiplex move up<CR>", desc = "Go top" },
		{ "<C-k>", "<CMD>Multiplex move up<CR>", desc = "Go up" },
		{ "<leader>wl", "<CMD>Multiplex move right<CR>", desc = "Go right" },
		{ "<C-l>", "<CMD>Multiplex move right<CR>", desc = "Go right" },

		{ "<leader>wm", "<CMD>new<CR>", desc = "New horizontal" },
		{ "<leader>wn", "<CMD>vnew<CR>", desc = "New vertical" },
		{ "<leader>wo", "<CMD>wincmd o<CR>", desc = "Close others" },
		{ "<leader>wq", "<CMD>q<CR>", desc = "Quit current" },
		{ "<leader>wr", "<CMD>wincmd J<CR>", desc = "Rotate vertical" },
		{ "<leader>ws", "<CMD>split<CR>", desc = "Split horizontal" },
		{ "<leader>wt", "<CMD>wincmd T<CR>", desc = "Move to new tab" },
		{ "<leader>wv", "<CMD>vsplit<CR>", desc = "Split vertical" },
		{ "<leader>ww", "<CMD>update<CR>", desc = "Save current buffer" },
		{ "<leader>wx", "<CMD>x<CR>", desc = "Save & Quit" },
		{ "<leader>wz", "<CMD>ZenMode<CR>", desc = "ZenMode" },

		{ "<M-h>", "<CMD>Multiplex resize left<CR>", desc = "Resize windows left" },
		{ "<M-j>", "<CMD>Multiplex resize down<CR>", desc = "Resize windows down" },
		{ "<M-k>", "<CMD>Multiplex resize up<CR>", desc = "Resize windows up" },
		{ "<M-l>", "<CMD>Multiplex resize right<CR>", desc = "Resize windows right" },

		{ "<leader>y", group = "Yank", nowait = false, remap = false },
		{ "<leader>yt", "<CMD>%yank<CR>", desc = "Yank all buffer", nowait = false, remap = false },
		{ "<leader>ym", "<CMD>ElixirDev yank_module_name<CR>", desc = "Yank module name" },

		{ "gt", "<CMD>ElixirDev jump_to_test<CR>", desc = "Test file or back" },
	}

	-- Better escape using jk in insert and terminal mode
	noremap("i", "jk", "<ESC>", "Scape with jk same as <ESC>")
	-- noremap("t", "jk", "<C-\\><C-n>", "")

	-- Center search results
	noremap("n", "n", "nzz", "Go to next found")
	noremap("n", "N", "Nzz", "Go to previous found")

	-- Visual line wraps
	xnoremap("n", "k", "v:count == 0 ? 'gk' : 'k'", "Move up")
	xnoremap("n", "j", "v:count == 0 ? 'gj' : 'j'", "Move down")

	-- Better indent
	noremap("v", "<", "<gv", "Indent and reselect")
	noremap("v", ">", ">gv", "Remove indent and reselect")

	-- Move selected line / block of text in visual mode
	noremap("x", "<Up>", ":move '<-2<CR>gv-gv", "Move selected up")
	noremap("x", "<Down>", ":move '>+1<CR>gv-gv", "Move seleced down")

	-- better search
	map("n", "*", "<CMD>Danielws better_search<CR>", "Search foward word under cursor")
	map("v", "*", "<CMD>Danielws better_search<CR>", "Search foward selection")

	-- Avoid starting macro recording by chance
	noremap("n", "Q", "q", "Record macro")
	noremap("n", "q", "<Nop>", "Nothing")

	local hop = require("hop")
	local directions = require("hop.hint").HintDirection

	vim.keymap.set("", "f", function()
		hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
	end, { remap = true })

	vim.keymap.set("", "F", function()
		hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
	end, { remap = true })

	vim.keymap.set("", "t", function()
		hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
	end, { remap = true })

	vim.keymap.set("", "T", function()
		hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
	end, { remap = true })

	local whichkey = require("which-key")

	whichkey.add(normal_lead_binds)
	whichkey.add(visual_lead_binds)
end

return M
