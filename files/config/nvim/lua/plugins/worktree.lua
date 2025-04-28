return {
	"ThePrimeagen/git-worktree.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local ts = require("telescope")
		ts.load_extension("git_worktree")

		local function opts(desc)
			return { desc = desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>fw", function()
			ts.extensions.git_worktree.git_worktree()
		end, opts("Find Worktrees"))
		vim.keymap.set("n", "<leader>fW", function()
			ts.extensions.git_worktree.create_git_worktree()
		end, opts("Create Worktrees"))
	end,
}
