local M = {}

M.default_config = {
	save_on_close = false,
	signcolumn = true,
	hooks = {
		on_win_open = function(buf, win) end,
		on_win_close = function(buf, win) end,
	},
}

--- @class Hooks
--- @field on_win_open function<string, string>
--- @field on_win_close function<string, string>
---
--- @class Configuration
--- @field save_on_close boolean
--- @field signcolumn boolean
--- @field hooks Hooks
---
--- @type Configuration
M.config = {}

function M.configure(opts)
	M.config = vim.tbl_deep_extend("force", M.default_config, opts or {})
end

return M
