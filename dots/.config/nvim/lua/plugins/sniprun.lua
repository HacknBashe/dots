return {
	"michaelb/sniprun",
	config = function()
		vim.api.nvim_set_keymap("v", "<leader>r", ":SnipRun<CR>", { silent = true })
		require("sniprun").setup({})
	end,
}
