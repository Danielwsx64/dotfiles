local ls = require("luasnip")

-- some shorthands...
local snippet = ls.snippet
local sn = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local fn = ls.function_node
local choice = ls.choice_node
local dynamic = ls.dynamic_node
-- local r = ls.restore_node
-- local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.expand_conditions")
-- local helper = require("snippets_helpers")

local function module_name()
	local module = "Module"

	local status_ok, elixir = pcall(require, "danielws.elixir")

	if status_ok then
		module = elixir.module_name_by_path()
	end

	return sn(nil, { insert(1, module) })
end

local function get_alias(args)
	local alias = string.match(args[1][1], "(.*)Test$")

	if alias then
		return alias
	end

	return args[1][1]
end

local function get_alias_suffix(args)
	local alias = get_alias(args)

	local sufix = string.match(alias, "([_%w]*)$")

	if sufix then
		return sufix
	end

	return alias
end

local function get_root(args)
	local root = string.match(args[1][1], "([_%w]*)%.")

	if root then
		return root
	end

	return args[1][1]
end

local function choice_anonimous_fn(_, _, _, mode)
	if mode == "arity_one" then
		return sn(nil, {
			choice(1, {
				sn(nil, fmt("& &{}", { insert(1, "1") })),
				sn(nil, fmt("fn {} -> {}{} end", { insert(1, "item"), rep(1), insert(2) })),
			}),
		})
	end

	if mode == "arity_two" then
		return sn(nil, {
			choice(1, {
				sn(nil, fmt("& &{}", { insert(1, "1") })),
				sn(nil, fmt("fn {}, {} -> {} end", { insert(1, "item"), insert(2, "acc"), insert(3) })),
			}),
		})
	end

	return sn(nil, { insert(1) })
end

return {
	snippet({ trig = "defmo", dscr = "Define a new module" }, {
		text("defmodule "),
		dynamic(1, module_name, {}),
		text({ " do", "" }),
		insert(0),
		text({ "", "end" }),
	}),
	snippet(
		{ trig = "exunit", dscr = "Define a new test module" },
		fmt(
			[[
defmodule {} do
	use {}.{}, async: {}

	alias {}

	describe "{}/{}" do
		test "{}" do
		  {}
		  assert {}.{}() == []
		end
	end
end
]],
			{
				dynamic(1, module_name, {}),
				choice(2, { insert(2, "ExUnit"), fn(get_root, 1, {}) }),
				choice(3, { insert(3, "Case"), text("DataCase"), text("ConnCase") }),
				choice(4, { text("true"), text("false") }),
				fn(get_alias, 1, {}),
				insert(5, "function_name"),
				insert(6, "0"),
				insert(7, "scenery"),
				insert(0),
				fn(get_alias_suffix, 1, {}),
				rep(5),
			}
		)
	),
}
