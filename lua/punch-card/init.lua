--- @class PunchCard
--- @field buf_name function
--- @field setup function<PunchCardOpts>
--- @field open function
--- @field close function
--- @field save_and_close function

local M = {}

local utils = require("punch-card.utils")

local punch_card_buf_name = "punch-card://editor"

local function get_all_punch_card_windows(buf)
	local wins = {}

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			table.insert(wins, win)
		end
	end

	return wins
end

local function handle_close(buf)
	local config = require("punch-card.config").config
	local wins = get_all_punch_card_windows(buf)

	for _, win in ipairs(wins) do
		config.hooks.before_win_close(buf, win)
		vim.api.nvim_win_close(win, true)
		config.hooks.after_win_close(buf)
	end
end

local function set_sign(buf, i, sign_name, text)
	vim.fn.sign_define(sign_name, {
		text = text,
		texthl = "Comment",
		numhl = "",
	})

	vim.fn.sign_place(1000 + i, "registers", sign_name, buf, { lnum = i })
end

local function set_signs(buf, regs)
	-- setup sign column
	vim.fn.sign_unplace("registers")

	for i, reg in ipairs(regs) do
		local sign_name = utils.ordered_signcolumns[i]
		set_sign(buf, i, sign_name, reg.name)
	end
end

local function fix_recurse(buf, lines)
	if #lines == 26 then
		return lines
	end

	local placed = vim.fn.sign_getplaced(buf, { group = "registers" })
	local current_signs = {}
	local signs = placed[1] and placed[1].signs or {}

	for _, s in ipairs(signs) do
		current_signs[tostring(s.lnum)] = s.name
	end

	-- check for missing lines
	local line_count = vim.api.nvim_buf_line_count(buf)
	local added = -1
	local deleted = -1

	for i = 1, line_count do
		local current = current_signs[tostring(i)]
		local expected = utils.ordered_signcolumns[i]

		if not current then
			added = i
			break
		end

		if current ~= expected then
			deleted = i
			break
		end
	end

	if deleted == -1 and added == -1 then
		return lines
	end

	if added ~= -1 then
		table.remove(lines, added)
	else -- here deleted is not -1
		table.insert(lines, deleted, "")
		set_sign(buf, deleted, utils.ordered_signcolumns[deleted], utils.alphabet[deleted])
	end

	return fix_recurse(buf, lines)
end

local function track(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	lines = fix_recurse(buf, lines)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	set_signs(buf, utils.get_registers())
end

function M.buf_name()
	return punch_card_buf_name
end

--- @param opts PunchCardOpts
function M.setup(opts)
	require("punch-card.config").configure(opts)
end

function M.open()
	local config = require("punch-card.config").config

	config.hooks.before_buf_create()

	-- create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "registers", { buf = buf })
	vim.api.nvim_buf_set_name(buf, punch_card_buf_name)

	-- gather all registers a–z
	local regs = utils.get_registers()
	local lines, reg_map = {}, {}

	for i, reg in ipairs(regs) do
		lines[i] = reg.value ~= "" and utils.reg_to_display(reg.value) or ""
		reg_map[i] = reg.name
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_var(buf, "reg_map", reg_map)

	config.hooks.before_win_open(buf)

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

	config.hooks.after_win_open(buf, win)

	vim.api.nvim_set_option_value("numberwidth", 2, { win = win })
	vim.api.nvim_set_option_value("signcolumn", "yes:1", { win = win })

	set_signs(buf, regs)

	if config.linenumbers then
		local number = vim.api.nvim_get_option_value("number", { scope = "global" })
		local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "global" })
		vim.api.nvim_set_option_value("number", number, { win = win })
		vim.api.nvim_set_option_value("relativenumber", relativenumber, { win = win })
	end

	-- handle :w to write back to registers
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			config.hooks.before_save(buf, win)
			local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local map = vim.api.nvim_buf_get_var(buf, "reg_map")

			for i, line in ipairs(new_lines) do
				local reg_name = map[i]
				if reg_name then
					vim.fn.setreg(reg_name, utils.display_to_reg(line))
				end
			end

			config.hooks.after_save(buf, win)
		end,
	})

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT" }, {
		buffer = buf,
		callback = function()
			track(buf)
		end,
	})
end

function M.close()
	local buf = vim.fn.bufnr(punch_card_buf_name)
	handle_close(buf)
end

function M.save_and_close()
	local buf = vim.fn.bufnr(punch_card_buf_name)

	vim.api.nvim_buf_call(buf, function()
		vim.cmd.write()
	end)

	handle_close(buf)
end

return M
