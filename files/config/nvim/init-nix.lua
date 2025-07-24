require("core.set")
require("core.remap")
require("core.github")
require("core.tmux")

require("plugins.formatter").config()
require("plugins.hexokinase").config()
require("plugins.markdown").render.config()
require("plugins.mini").config()

-- Get lazy working like this
-- https://github.com/Kidsan/nixos-config/blob/bfa828714b8f889c362cddbf9799d6ec8056a7b3/home/programs/neovim/nvim/init.lua#L4
if vim.g.vscode then
	local vscode = require("vscode")
else
	require("plugins.better-vim-tmux-resizer")
	require("plugins.mcp-hub").config()
	require("plugins.copilot").copilot.config()
	require("plugins.copilot").copilotcmp.config()
	require("plugins.neogit").config()
	require("plugins.gitsigns").config()
	require("plugins.harpoon").config()
	require("plugins.lsp")
	require("plugins.markdown").toc.config()
	require("plugins.mini-files")
	require("plugins.obsidian").config()
	require("plugins.sniprun").config()
	require("plugins.telescope").config()
	require("plugins.theme").tokyonight.config()
	require("plugins.treesitter").config()
	require("plugins.trouble").config()
	require("plugins.telescope-undo").config()
end
