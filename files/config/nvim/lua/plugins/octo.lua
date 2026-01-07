return {
	"pwntester/octo.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("octo").setup({})

		-- Keybindings
		vim.keymap.set("n", "<leader>oi", "<CMD>Octo issue list<CR>", { desc = "List GitHub Issues" })
		vim.keymap.set("n", "<leader>oo", "<CMD>Octo pr browser<CR>", { desc = "Open PR in Browser" })
		vim.keymap.set("n", "<leader>op", "<CMD>Octo pr list<CR>", { desc = "List GitHub PullRequests" })
		vim.keymap.set("n", "<leader>od", "<CMD>Octo discussion list<CR>", { desc = "List GitHub Discussions" })
		vim.keymap.set("n", "<leader>on", "<CMD>Octo notification list<CR>", { desc = "List GitHub Notifications" })
		vim.keymap.set("n", "<leader>or", "<CMD>Octo review start<CR>", { desc = "Start GitHub PR Review" })
		vim.keymap.set("n", "<leader>os", function()
			require("octo.utils").create_base_search_command({ include_current_repo = true })
		end, { desc = "Search GitHub" })
	end,
}
