return {
	"tpope/vim-fugitive",
	config = function()
		local function opts(desc)
			return { desc = desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>gG", ":vertical Git <CR>", opts("Git Fugitive"))
		-- vim.keymap.set(
		-- 	"n",
		-- 	"<leader>gb",
		-- 	"<cmd>Git blame<CR>",
		-- 	{ desc = "Git Blame Line", noremap = true, silent = true, nowait = true }
		-- )
		vim.keymap.set(
			"n",
			"<leader>gL",
			"<cmd>:vertical Git log<CR>",
			{ desc = "Git log", noremap = true, silent = true, nowait = true }
		)
		vim.keymap.set(
			"n",
			"<leader>gf",
			"<cmd>:vertical Git log --follow -- %<CR>",
			{ desc = "Git file history", noremap = true, silent = true, nowait = true }
		)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "fugitive", "fugitiveblame", "git" },
			callback = function()
				vim.api.nvim_buf_set_keymap(0, "n", "<C-c>", ":q<CR>", {
					noremap = true,
					silent = true,
					desc = "Exit fugitive buffer",
				})
			end,
		})
	end,
}
