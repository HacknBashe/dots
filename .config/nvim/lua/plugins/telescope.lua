return {
	-- Fuzzy finder
	"nvim-telescope/telescope.nvim",
	tag = "0.1.1",
	-- or                            , branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	config = function()
		local builtin = require("telescope.builtin")
		-- find
		vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
		vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
		-- vim.keymap.set("n", "<leader>fs", function()
		-- 	builtin.grep_string({ search = vim.fn.input("Grep > ") })
		-- end)
		vim.keymap.set("n", "<leader>fs", "<cmd> Telescope live_grep <CR>")
		vim.keymap.set("n", "<leader>fr", "<cmd> Telescope oldfiles <CR>", {}, "find recent files")
		vim.keymap.set("n", "<leader>fh", "<<cmd> Telescope help_tags <CR>", {}, "help page")

		-- ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "find all" },
		-- ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "find buffers" },
		-- ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "find in current buffer" },

		-- git
		vim.keymap.set("n", "<leader>gc", "<cmd> Telescope git_commits <CR>", {}, "git commits")
		vim.keymap.set("n", "<leader>gs", "<cmd> Telescope git_status <CR>", {}, "git status")

		require("telescope").load_extension("fzf")
		require("telescope").setup({
			defaults = {
				vimgrep_arguments = {
					"rg",
					"-L",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				prompt_prefix = "   ",
				selection_caret = "  ",
				entry_prefix = "  ",
				initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				file_ignore_patterns = { "node_modules" },
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				path_display = { "truncate" },
				winblend = 0,
				-- border = false,
				-- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				color_devicons = true,
				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				-- Developer configurations: Not meant for general override
				buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
				mappings = {
					n = { ["q"] = require("telescope.actions").close },
				},
			},
		})
	end,
}
