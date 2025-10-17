local M = {}

--- @class KeychainHooks
--- @field before_buf_create? function
--- @field before_win_open? function<number>
--- @field after_win_open? function<number, number>
--- @field before_save? function<number, number>
--- @field after_save? function<number, number>
--- @field before_win_close? function<number, number>
--- @field after_win_close? function<number>
---
--- @class KeychainOpts
--- @field linenumbers? boolean
--- @field hooks? KeychainHooks

--- @type KeychainOpts
M.default_config = {
	linenumbers = true,
	hooks = {
		before_buf_create = function() end,
		before_win_open = function(buf) end,
		after_win_open = function(buf, win) end,
		before_save = function(buf, win) end,
		after_save = function(buf, win) end,
		before_win_close = function(buf, win) end,
		after_win_close = function(buf) end,
	},
}

--- @type KeychainOpts
M.config = {}

--- @param opts KeychainOpts
function M.configure(opts)
	M.config = vim.tbl_deep_extend("force", M.default_config, opts or {})
end

return M
