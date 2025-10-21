# punch-card.nvim

your punch-card is a buffer which lets you edit your registers

## installation

with lazy.nvim

```lua
return {
	"skyppex/punch-card.nvim",
	config = function()
		-- configure punch-card
		--- @type PunchCardOpts
		local opts = {
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

		require("punch-card").setup(opts)
	end,
}
```

## usage

to use `punch-card` you have to use its api

```lua
-- import punch-card and optionally give it its type for some lsp help
--- @type PunchCard
local punch_card = require("punch-card")

-- open the punch-card editor
-- while you are editing, make sure to
-- write the buffer with :w to save your changes
punch_card.open()

-- close the punch-card editor
-- this closes all windows with the punch-card buffer if you have multiple
punch_card.close()

-- you can also save and close in one go if you
-- wish to avoid having to remember to save
punch_card.save_and_close()
```

## known issues

- some poor behaviour when deleting multiple lines at once with `5d` and or visual selection.
	- might lead to registers being duplicated or values moved between registers

## contributing

issues and pull requests are welcome! please make an issue for feature requests
before doing any work on a pr

## license - MIT

see LICENSE file
