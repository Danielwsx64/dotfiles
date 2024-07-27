local header = {
	[[                                                                              ]],
	[[                                    ██████                                    ]],
	[[                                ████▒▒▒▒▒▒████                                ]],
	[[                              ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
	[[                            ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                            ]],
	[[                          ██▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒                              ]],
	[[                          ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▓▓▓▓                          ]],
	[[                          ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▒▒▓▓                          ]],
	[[                        ██▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒    ██                        ]],
	[[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
	[[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
	[[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
	[[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
	[[                        ██▒▒██▒▒▒▒▒▒██▒▒▒▒▒▒▒▒██▒▒▒▒██                        ]],
	[[                        ████  ██▒▒██  ██▒▒▒▒██  ██▒▒██                        ]],
	[[                        ██      ██      ████      ████                        ]],
	[[                                                                              ]],
	[[                                                                              ]],
}

local function footer()
	-- Number of plugins
	local total_plugins = require("lazy").stats().count
	local datetime = os.date("%d-%m-%Y  %H:%M:%S")
	local plugins_text = "\t" .. total_plugins .. " plugins  " .. datetime

	-- Quote
	local fortune = require("alpha.fortune")
	local quote = table.concat(fortune(), "\n")

	return plugins_text .. "\n" .. quote
end

return {
	"goolord/alpha-nvim",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		local button = dashboard.button
		dashboard.leader = "daniel"

		dashboard.section.header.val = header
		dashboard.section.header.opts.hl = "Type"

		dashboard.section.buttons.val = {
			button("SPC SPC f", "◎ Find file", "<CMD>Telescope find_files<CR>"),
			button("e", " New file", "<CMD>ene <CR>"),
			button("SPC c e", " Configuration", ":e $MYVIMRC <CR>"),
			button("SPC z s", " Lazy sync", "<CMD>Lazy sync<CR>"),
		}

		dashboard.section.buttons.opts.hl = "Function"
		dashboard.section.buttons.opts.hl_shortcut = "Type"

		dashboard.section.footer.val = footer()
		dashboard.section.footer.opts.hl = "Constant"

		require("alpha").setup({
			layout = {
				{ type = "padding", val = 2 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				dashboard.section.footer,
			},
			opts = {
				margin = 5,
				noautocmd = true,
			},
		})
	end,
}
