return {
	"chasnovski/mini.nvim",
	lazy = false,
	config = function()
		local starter = require("mini.starter")
		starter.setup({
			evaluate_single = true,
			items = {
				starter.sections.builtin_actions(),
				starter.sections.recent_files(9, true),
			},
			content_hooks = {
				starter.gen_hook.adding_bullet(),
				starter.gen_hook.indexing("all", { "Builtin actions" }),
				starter.gen_hook.padding(3, 2),
				starter.gen_hook.aligning("center", "center"),
			},
			header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
			footer = " ",
		})

		local mininotify = require("mini.notify")
		vim.notify = mininotify.make_notify()
		mininotify.setup({
			window = {
				winblend = 0,
			},
		})
		vim.keymap.set("n", "<leader>nh", function()
			mininotify.show_history()
		end, { desc = "Notification history", noremap = true, silent = true, nowait = true })
		vim.keymap.set("n", "<leader>nd", function()
			mininotify.clear()
		end, { desc = "Dismiss Notifications", noremap = true, silent = true, nowait = true })

		local files = require("mini.files")
		files.setup()
		vim.keymap.set("n", "<leader>ft", function()
			files.open(vim.api.nvim_buf_get_name(0))
		end, { desc = "File Tree", noremap = true })
		require("mini.pick").setup()
		require("mini.diff").setup({
			view = { style = "sign", signs = { add = "│", change = "┆", delete = "_" } },
		})
		require("mini.icons").setup()
		require("mini.indentscope").setup()

		require("mini.cursorword").setup()
		require("mini.surround").setup()
		require("ts_context_commentstring").setup({
			enable_autocmd = false,
		})
		require("mini.comment").setup({
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
				end,
			},
		})

		local statusline = require("mini.statusline")
		statusline.setup()

		local clue = require("mini.clue")
		vim.o.timeout = true
		vim.o.timeoutlen = 300
		clue.setup({
			window = {
				config = {
					width = 40,
					height = 20,
					border = "rounded",
				},
				delay = 300,
			},

			triggers = {
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },

				{ mode = "i", keys = "<C-x>" },

				{ mode = "n", keys = "g" },
				{ mode = "n", keys = "z" },
				{ mode = "n", keys = "]" },
				{ mode = "n", keys = "[" },

				{ mode = "n", keys = "'" },
				{ mode = "n", keys = "`" },
				{ mode = "n", keys = '"' },

				{ mode = "n", keys = "<C-w>" },
			},

			clues = {
				clue.gen_clues.builtin_completion(),
				clue.gen_clues.g(),
				clue.gen_clues.marks(),
				clue.gen_clues.registers(),
				clue.gen_clues.windows(),
				clue.gen_clues.z(),

				{ mode = "n", keys = "<Leader>a", desc = "AI Agent" },
				{ mode = "n", keys = "<Leader>b", desc = "Buffer" },
				{ mode = "n", keys = "<Leader>d", desc = "Diagnostics" },
				{ mode = "n", keys = "<Leader>f", desc = "Find/File" },
				{ mode = "n", keys = "<Leader>fd", desc = "Find in Directory" },
				{ mode = "n", keys = "<Leader>g", desc = "Git" },
				{ mode = "n", keys = "<Leader>n", desc = "Notifications" },
				{ mode = "n", keys = "<Leader>q", desc = "Quickfix" },
				{ mode = "n", keys = "<Leader>t", desc = "Tables" },
				{ mode = "n", keys = "<Leader>v", desc = "View" },
			},
		})
	end,
}
