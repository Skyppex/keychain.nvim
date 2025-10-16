# keychain.nvim

your keychain is a buffer which lets you edit your registers

## installation

with lazy.nvim

```lua
return {
	"skyppex/keychain.nvim",
	config = function()
		-- configure keychain
		--- @type KeychainOpts
		local opts = {
			signcolumn = true,
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

		require("keychain").setup(opts)
	end,
}
```

## usage

to use `keychain` you have to use its api

```lua
-- import keychain and optionally give it its type for some lsp help
--- @type Keychain
local keychain = require("keychain")

-- open the keychain editor
-- while you are editing, make sure to
-- write the buffer with :w to save your changes
keychain.open()

-- close the keychain editor
-- this closes all windows with the keychain buffer if you have multiple
keychain.close()

-- you can also save and close in one go if you
-- wish to avoid having to remember to save
keychain.save_and_close()
```

## contributing

issues and pull requests are welcome! please make an issue for feature requests
before doing any work on a pr

## license - MIT

see LICENSE file

