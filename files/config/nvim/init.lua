local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("lazy").setup("plugins", {
	rocks = { enabled = false },
	install = {
		missing = false,
		colorscheme = { "tokyonight-moon" },
	},
})
vim.keymap.set("n", "<leader>vl", ":Lazy <CR>", { desc = "Lazy", noremap = true, silent = true, nowait = true })

require("core.set")
require("core.remap")
require("core.github")
require("core.tmux")
-- TODO: NVIM-NIX Fix this
-- require("core.treesitter")
