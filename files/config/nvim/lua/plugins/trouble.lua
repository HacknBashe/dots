-- Show diagnostics
return {
	"folke/trouble.nvim",
	config = function()
		vim.keymap.set(
			"n",
			"<leader>tq",
			"<cmd>Trouble diagnostics toggle<cr>",
			{ desc = "View Quickfix", silent = true, noremap = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tn",
			"<cmd>Trouble diagnostics next<cr><cmd>Trouble diagnostics focus<cr>",
			{ desc = "Trouble next diagnostic", silent = true, noremap = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tp",
			"<cmd>Trouble diagnostics prev<cr><cmd>Trouble diagnostics focus<cr>",
			{ desc = "Trouble prev diagnostic", silent = true, noremap = true }
		)

		require("trouble").setup()
	end,
}
