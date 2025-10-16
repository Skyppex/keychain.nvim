local M = {}

local keychain_buf_name = "keychain://editor"

function M.buf_name()
	return keychain_buf_name
end

function M.setup(opts)
	require("keychain.config").configure(opts)
end

function M.open()
	local config = require("keychain.config").config
	local utils = require("keychain.utils")

	-- create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "registers", { buf = buf })
	vim.api.nvim_buf_set_name(buf, keychain_buf_name)

	-- gather all registers a–z
	local regs = utils.get_registers()
	local lines, reg_map = {}, {}

	for i, reg in ipairs(regs) do
		lines[i] = reg.value ~= "" and utils.reg_to_display(reg.value) or ""
		reg_map[i] = reg.name
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_var(buf, "reg_map", reg_map)

	-- floating window setup
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.min(26, math.floor(vim.o.lines * 0.6))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Register Editor ",
		title_pos = "center",
	})

	config.hooks.on_win_open(buf, win)

	local number = vim.api.nvim_get_option_value("number", { scope = "global" })
	local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "global" })
	vim.api.nvim_set_option_value("number", number, { win = win })
	vim.api.nvim_set_option_value("relativenumber", relativenumber, { win = win })
	vim.api.nvim_set_option_value("numberwidth", 2, { win = win })

	-- setup sign column
	vim.fn.sign_unplace("registers")

	if config.signcolumn then
		vim.api.nvim_set_option_value("signcolumn", "yes:1", { win = win })

		for i, reg in ipairs(regs) do
			local sign_name = "RegisterSign_" .. reg.name
			pcall(vim.fn.sign_define, sign_name, {
				text = reg.name,
				texthl = "Comment",
				numhl = "",
			})
			vim.fn.sign_place(1000 + i, "registers", sign_name, buf, { lnum = i })
		end
	end

	-- handle :w to write back to registers
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local map = vim.api.nvim_buf_get_var(buf, "reg_map")

			for i, line in ipairs(new_lines) do
				local reg_name = map[i]
				if reg_name then
					vim.fn.setreg(reg_name, utils.display_to_reg(line))
				end
			end
		end,
	})
end

local function get_all_keychain_windows(buf)
	local wins = {}

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			table.insert(wins, win)
		end
	end

	return wins
end

local function handle_close(buf)
	local windows = get_all_keychain_windows(buf)

	for _, win in ipairs(windows) do
		vim.api.nvim_win_close(win, true)
	end
end

function M.close()
	local buf = vim.fn.bufnr(keychain_buf_name)
	handle_close(buf)
end

function M.save_and_close()
	local buf = vim.fn.bufnr(keychain_buf_name)

	vim.api.nvim_buf_call(buf, function()
		vim.cmd.write()
	end)

	handle_close(buf)
end

return M
