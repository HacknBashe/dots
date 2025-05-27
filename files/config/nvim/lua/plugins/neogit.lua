return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",

		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local neogit = require("neogit")

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "Neogit*",
			callback = function()
				vim.keymap.set("n", "<leader>goc", function()
					local word = vim.fn.expand("<cword>")
					OpenInGithub(word)
				end, { buffer = true, desc = "Git open commit in GitHub" })
			end,
		})

		vim.keymap.set("n", "<leader>gG", function()
			neogit.open({ kind = "vsplit" })
		end, { desc = "Git", noremap = true, silent = true, nowait = true })
		vim.keymap.set("n", "<leader>gL", function()
			neogit.open({ "log", kind = "vsplit" })
		end, { desc = "Git log", noremap = true, silent = true, nowait = true })
		vim.keymap.set("n", "<leader>gf", function()
			neogit.open({ "log", "--", vim.fn.expand("%") }, { kind = "vsplit" })
		end, { desc = "Git log for current file", noremap = true, silent = true, nowait = true })
	end,
}
