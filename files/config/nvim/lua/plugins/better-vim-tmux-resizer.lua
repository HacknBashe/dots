return {
	"RyanMillerC/better-vim-tmux-resizer",
	config = function()
		vim.keymap.set("n", "<C-w>h", "<cmd>TmuxResizeLeft<CR>")
		vim.keymap.set("n", "<C-w>j", "<cmd>TmuxResizeDown<CR>")
		vim.keymap.set("n", "<C-w>k", "<cmd>TmuxResizeUp<CR>")
		vim.keymap.set("n", "<C-w>l", "<cmd>TmuxResizeRight<CR>")
	end,
}
