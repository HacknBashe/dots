return {
	"kdheepak/lazygit.nvim",
	event = "VimEnter",
	config = function()
		vim.keymap.set(
			"n",
			"<leader>gl",
			"<cmd>LazyGit<CR>",
			{ desc = "LazyGit", noremap = true, silent = true, nowait = true }
		)
	end,
}
