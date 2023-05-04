vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", {})

-- Highlight text on yank
autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

function PositionHelp()
	vim.cmd("wincmd L")
	vim.api.nvim_win_set_width(0, 80)
end

autocmd("BufEnter", {
	group = yank_group,
	pattern = "",
	callback = function()
		-- local rightmost_win = winnr('r')
		if vim.api.nvim_buf_get_option(0, "buftype") == "help" then
			vim.defer_fn(PositionHelp, 1)
		end
	end,
})

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.colorcolumn = "80"
