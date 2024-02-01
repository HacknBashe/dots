function telescope_find_directory_file(subdirectory)
	require("telescope.builtin").find_files({
		prompt_title = "Search directory for file",
		cwd = subdirectory,
	})
end

function telescope_find_directory_string(subdirectory)
	require("telescope.builtin").live_grep({
		prompt_title = "Search directory for string",
		cwd = subdirectory,
	})
end

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.1",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	config = function()
		vim.keymap.set("n", "<leader>ff", "<cmd> Telescope find_files follow=true hidden=true <CR>")
		vim.keymap.set("n", "<leader>fs", "<cmd> Telescope live_grep <CR>")

		local fdfcmd =
			[[:lua telescope_find_directory_file(vim.fn.input("Search subdirectory for file: ", vim.fn.getreg('"'))<CR>]]
		vim.keymap.set("n", "<leader>fdf", fdfcmd, { noremap = true, silent = true })
		local fdscmd =
			[[:lua telescope_find_directory_string(vim.fn.input("Search subdirectory for string: ", vim.fn.getreg('"')))<CR>]]
		vim.keymap.set("n", "<leader>fds", fdscmd, { noremap = true, silent = true })

		vim.keymap.set("n", "<leader>fr", "<cmd> Telescope oldfiles <CR>")
		vim.keymap.set("n", "<leader>fh", "<cmd> Telescope help_tags <CR>")

		vim.keymap.set("n", "<leader>gc", "<cmd> Telescope git_commits <CR>")
		vim.keymap.set("n", "<leader>gs", "<cmd> Telescope git_status <CR>")

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
				-- file_ignore_patterns = { "node_modules" },
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
