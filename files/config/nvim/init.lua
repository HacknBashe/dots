-- Project-local shada: store marks, history, etc. per git repo/worktree
-- Must be set before shada is read (very early in startup)
-- Uses --git-dir to handle worktrees correctly (each worktree gets its own shada)
local git_dir = vim.fn.systemlist("git rev-parse --git-dir 2>/dev/null")[1]
if vim.v.shell_error == 0 and git_dir and git_dir ~= "" then
	-- Make path absolute if relative (happens when inside repo)
	if not git_dir:match("^/") then
		git_dir = vim.fn.getcwd() .. "/" .. git_dir
	end
	vim.o.shadafile = git_dir .. "/nvim.shada"
end

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
vim.g.maplocalleader = "\\"

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
require("core.notes")
require("core.marks")
