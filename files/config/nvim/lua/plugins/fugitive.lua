return {
	"tpope/vim-fugitive",
	config = function()
		local function opts(desc)
			return { desc = desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>gg", ":vertical Git <CR>", opts("Git Fugitive"))
		vim.keymap.set(
			"n",
			"<leader>gl",
			"<cmd>Git blame<CR>",
			{ desc = "Git Blame Line", noremap = true, silent = true, nowait = true }
		)
		vim.keymap.set(
			"n",
			"<leader>gL",
			"<cmd>:vertical Git log<CR>",
			{ desc = "Git log", noremap = true, silent = true, nowait = true }
		)
	end,
}
