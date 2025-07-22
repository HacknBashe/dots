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
		local builtin = require("telescope.builtin")

		vim.keymap.set("n", "<leader>ff", "<cmd> Telescope find_files hidden=true follow=true <CR>", opts("Find Files"))
		vim.keymap.set("n", "<leader>fs", "<cmd> Telescope live_grep <CR>", opts("Find Strings"))
		vim.keymap.set("v", "<leader>fs", builtin.grep_string, opts("Find Selected Text"))

		vim.keymap.set("n", "<leader>fm", "<cmd> Telescope marks<CR>", opts("View Marks"))

		vim.keymap.set("n", "<leader>fdf", function()
			builtin.find_files({
				prompt_title = "Select Directory",
				find_command = { "find", ".", "-type", "d", "-not", "-path", "*/.*" },
				attach_mappings = function(prompt_bufnr, map)
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")

					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)

						builtin.find_files({
							prompt_title = "Search directory for file",
							cwd = selection.value,
						})
					end)

					return true
				end,
			})
		end, opts("Find file in directory"))

		vim.keymap.set("n", "<leader>fds", function()
			builtin.find_files({
				prompt_title = "Select Directory",
				find_command = { "find", ".", "-type", "d", "-not", "-path", "*/.*" },
				attach_mappings = function(prompt_bufnr, map)
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")

					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)

						builtin.live_grep({
							prompt_title = "Search directory for string",
							cwd = selection.value,
						})
					end)

					return true
				end,
			})
		end, opts("Find string in directory"))

		vim.keymap.set("n", "<leader>fb", "<cmd> Telescope buffers <CR>", opts("Find Buffers"))
		vim.keymap.set("n", "<leader>fr", "<cmd> Telescope oldfiles cwd_only=true <CR>", opts("Find Recent in CWD"))
		vim.keymap.set("n", "<leader>fh", "<cmd> Telescope help_tags <CR>", opts("Find Help"))

		vim.keymap.set("n", "<leader>fR", "<cmd> Telescope resume <CR>", opts("Find: Resume Last Search"))

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
				file_ignore_patterns = {
					"^.git/", -- Git directory
					"^.cache/", -- Cache directory
					"^node_modules/", -- Node modules
				},
			},
		})
	end,
}
