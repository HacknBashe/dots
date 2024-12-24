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
		local function opts(desc)
			return { desc = desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>ff", "<cmd> Telescope find_files follow=true <CR>", opts("Find Files"))
		vim.keymap.set("n", "<leader>fs", "<cmd> Telescope live_grep <CR>", opts("Find Strings"))

		local fdfcmd =
			[[:lua telescope_find_directory_file(vim.fn.input("Search subdirectory for file: ", vim.fn.getreg('"'))<CR>]]
		vim.keymap.set("n", "<leader>fdf", fdfcmd, opts("Find file in directory"))
		local fdscmd =
			[[:lua telescope_find_directory_string(vim.fn.input("Search subdirectory for string: ", vim.fn.getreg('"')))<CR>]]
		vim.keymap.set("n", "<leader>fds", fdscmd, opts("Find string in directory"))

		vim.keymap.set("n", "<leader>fb", "<cmd> Telescope buffers <CR>", opts("Find Buffers"))
		vim.keymap.set("n", "<leader>fr", "<cmd> Telescope oldfiles <CR>", opts("Find Recent"))
		vim.keymap.set("n", "<leader>fh", "<cmd> Telescope help_tags <CR>", opts("Find Help"))

		vim.keymap.set("n", "<leader>fR", "<cmd> Telescope resume <CR>", opts("Find: Resume Last Search"))

		vim.keymap.set("n", "<leader>gc", "<cmd> Telescope git_commits <CR>", opts("Git Commits"))
		vim.keymap.set("n", "<leader>gs", "<cmd> Telescope git_status <CR>", opts("Git Status"))

		require("telescope").load_extension("fzf")
		local horiztonal = {
			prompt_position = "top",
			width = 0.9,
			preview_width = 0.5,
			preview_cutoff = 90,
		}
		local vertical = {
			mirror = true,
			prompt_position = "top",
			width = 0.9,
			preview_height = 0.4,
			preview_cutoff = 25,
		}
		require("telescope").setup({
			defaults = {
				prompt_prefix = "   ",
				selection_caret = "  ",
				sorting_strategy = "ascending",
				layout_strategy = "flex",
				layout_config = {
					horizontal = horiztonal,
					vertical = vertical,
					flex = {
						flip_colums = 100,
						horizontal = horiztonal,
						vertical = vertical,
					},
				},

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
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				path_display = { "truncate" },
				set_env = { ["COLORTERM"] = "truecolor" },
				mappings = {
					n = { ["q"] = require("telescope.actions").close },
				},
			},
		})
	end,
}
