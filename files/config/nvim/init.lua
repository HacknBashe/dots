require("core.set")
require("core.remap")

require("plugins.better-vim-tmux-resizer")
require("plugins.code-companion").config()
require("plugins.copilot").copilot.config()
require("plugins.copilot").copilotcmp.config()
require("plugins.formatter").config()
require("plugins.fugitive").config()
require("plugins.harpoon").config()
require("plugins.hexokinase").config()
require("plugins.lsp")
require("plugins.markdown").toc.config()
require("plugins.markdown").render.config()
require("plugins.mini").config()
require("plugins.mini-files")
require("plugins.obsidian").config()
require("plugins.oil").config()
require("plugins.sniprun").config()
require("plugins.telescope").config()
require("plugins.theme").tokyonight.config()
require("plugins.treesitter").config()
require("plugins.trouble").config()
require("plugins.telescope-undo").config()
require("plugins.yazi").config()

-- -- Bootstrap lazy
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
-- 	vim.fn.system({
-- 		"git",
-- 		"clone",
-- 		"--filter=blob:none",
-- 		"https://github.com/folke/lazy.nvim.git",
-- 		"--branch=stable", -- latest stable release
-- 		lazypath,
-- 	})
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- vim.keymap.set("n", "<leader>vl", ":Lazy <CR>", { desc = "View Lazy" })
--
-- require("lazy").setup("plugins", {})
