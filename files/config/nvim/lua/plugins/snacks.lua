return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		Snacks = require("snacks")
		Snacks.setup({
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{
						pane = 2,
						icon = " ",
						title = "Recent Files",
						section = "recent_files",
						indent = 2,
						padding = 1,
					},
					{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{
						pane = 2,
						icon = " ",
						title = "Git Status",
						section = "terminal",
						enabled = function()
							return Snacks.git.get_root() ~= nil
						end,
						cmd = "git status --short --branch --renames",
						height = 5,
						padding = 1,
						ttl = 5 * 60,
						indent = 3,
					},
				},
			},
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			-- scroll = {
			-- 	enabled = true,
			-- 	animate = {
			-- 		duration = { step = 10, total = 100 },
			-- 		easing = "inOutQuad",
			-- 	},
			-- },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		})

		vim.keymap.set("n", "<leader>z", function()
			Snacks.zen()
		end, { desc = "Zen Mode", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>Z", function()
			Snacks.zen.zoom()
		end, { desc = "Zoom Mode", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>.", function()
			Snacks.scratch()
		end, { desc = "Toggle Scratch Buffer", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>nh", function()
			Snacks.notifier.show_history()
		end, { desc = "Notification history", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>nd", function()
			Snacks.notifier.hide()
		end, { desc = "Dismiss Notifications", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>gg", function()
			Snacks.lazygit()
		end, { desc = "LazyGit", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>gB", function()
			Snacks.gitbrowse()
		end, { desc = "Git Browse", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>gL", function()
			Snacks.git.lazygit.log()
		end, { desc = "Git Log", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>gf", function()
			Snacks.git.lazygit.log_file()
		end, { desc = "Git File History", noremap = true, silent = true, nowait = true })

		vim.keymap.set("n", "<leader>gl", function()
			Snacks.git.blame_line()
		end, { desc = "Git Blame Line", noremap = true, silent = true, nowait = true })
	end,
}
