return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",

		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local neogit = require("neogit")

		vim.keymap.set("n", "<leader>gg", function()
			neogit.open({ kind = "vsplit" })
		end, { desc = "Git", noremap = true, silent = true, nowait = true })
		vim.keymap.set("n", "<leader>gL", function()
			neogit.open({ "log", kind = "vsplit" })
		end, { desc = "Git log", noremap = true, silent = true, nowait = true })
	end,
}
