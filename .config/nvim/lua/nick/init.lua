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

require("nick.set")
require("nick.remap")
