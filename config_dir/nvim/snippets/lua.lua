local ls = require("luasnip")

local snippet = ls.snippet
local text = ls.text_node
local insert = ls.insert_node

return {
	snippet({ trig = "vins", dscr = "Vim inspect and print" }, {
		text("print(vim.inspect("),
		insert(0),
		text("))"),
	}),
}
