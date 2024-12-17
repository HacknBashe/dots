-- Show diagnostics
return {
	"folke/trouble.nvim",
	config = function()
		vim.keymap.set(
			"n",
			"<leader>dq",
			"<cmd>Trouble diagnostics toggle<cr>",
			{ desc = "Diagnostic Quickfix List", silent = true, noremap = true }
		)

		vim.keymap.set(
			"n",
			"<leader>dq",
			"<cmd>Trouble diagnostics toggle<cr>",
			{ desc = "Diagnostic Quickfix List", silent = true, noremap = true }
		)
		vim.keymap.set(
			"n",
			"<leader>dn",
			"<cmd>Trouble diagnostics next<cr><cmd>Trouble diagnostics focus<cr>",
			{ desc = "Diagnostic: Next", silent = true, noremap = true }
		)
		vim.keymap.set(
			"n",
			"<leader>dp",
			"<cmd>Trouble diagnostics prev<cr><cmd>Trouble diagnostics focus<cr>",
			{ desc = "Diagnostic: Prev", silent = true, noremap = true }
		)

		require("trouble").setup()
	end,
}
