local M = {}

function M.open_in_browser(mode)
	local gitlinker = require("gitlinker")

	gitlinker.get_buf_range_url(mode, { action_callback = Self.open_browser })
end

function M.copy_link(mode)
	local gitlinker = require("gitlinker")

	gitlinker.get_buf_range_url(mode)
end

function M.open_browser(url)
	require("plenary.job"):new({ command = "firefox", args = { url } }):sync()
end

return M
