local M = {}

--- @return table<string, string>
function M.get_registers()
	local regs = {}
	for i = string.byte("a"), string.byte("z") do
		local name = string.char(i)
		local val = vim.fn.getreg(name)
		regs[#regs + 1] = { name = name, value = val }
	end
	return regs
end

-- convert termcodes to readable text
--- @param str string
--- @return string
function M.reg_to_display(str)
	return vim.fn.keytrans(str)
end

-- convert readable text to termcodes
--- @param str string
--- @return string
function M.display_to_reg(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return M
