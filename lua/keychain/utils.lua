local M = {}

M.ordered_signcolumns = {
	"RegisterSign_a",
	"RegisterSign_b",
	"RegisterSign_c",
	"RegisterSign_d",
	"RegisterSign_e",
	"RegisterSign_f",
	"RegisterSign_g",
	"RegisterSign_h",
	"RegisterSign_i",
	"RegisterSign_j",
	"RegisterSign_k",
	"RegisterSign_l",
	"RegisterSign_m",
	"RegisterSign_n",
	"RegisterSign_o",
	"RegisterSign_p",
	"RegisterSign_q",
	"RegisterSign_r",
	"RegisterSign_s",
	"RegisterSign_t",
	"RegisterSign_u",
	"RegisterSign_v",
	"RegisterSign_w",
	"RegisterSign_x",
	"RegisterSign_y",
	"RegisterSign_z",
}

M.alphabet = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
}

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
