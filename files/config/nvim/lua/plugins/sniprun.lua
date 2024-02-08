return {
	"michaelb/sniprun",
	config = function()
		vim.api.nvim_set_keymap("v", "<leader>r", ":SnipRun<CR>", { silent = true })
		vim.api.nvim_set_keymap("n", "<leader>r", ":SnipRun<CR>", { silent = true })
		vim.api.nvim_set_keymap("n", "<leader>R", "gg<S-v><S-g>:SnipRun<CR>", { silent = true })
		require("sniprun").setup({
			display = {
				"TempFloatingWindow",
			},
		})
	end,
}
