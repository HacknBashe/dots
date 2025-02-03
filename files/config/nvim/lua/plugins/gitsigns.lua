return { -- Git
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
		})

		vim.keymap.set(
			"n",
			"<leader>gl",
			"<cmd>Gitsigns toggle_current_line_blame<CR>",
			{ desc = "Git Blame Line", noremap = true, silent = true, nowait = true }
		)
	end,
}
