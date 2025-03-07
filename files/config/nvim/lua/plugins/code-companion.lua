return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			display = {
				action_palette = {
					provider = "mini_pick",
				},
				chat = {
					show_settings = true,
				},
			},
			adapters = {
				opts = {
					show_defaults = false,
					log_level = "DEBUG",
				},
				-- ml_nlp = require("plugins.cc-ml-nlp"),
				claude = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "claude-3.7-sonnet",
							},
							max_tokens = {
								default = 65536,
							},
						},
					})
				end,
				o3 = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "o3-mini-2025-01-31",
							},
							max_tokens = {
								default = 65536,
							},
						},
					})
				end,
				["4o"] = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "gpt-4o",
							},
							max_tokens = {
								default = 65536,
							},
						},
					})
				end,
			},
			strategies = {
				chat = {
					adapter = "claude",
				},
				inline = {
					adapter = "claude",
				},
			},
		})
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ac",
			"<cmd>CodeCompanionChat Toggle<cr>",
			{ desc = "AI Chat", noremap = true, silent = true }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>aA",
			"<cmd>CodeCompanionActions<cr>",
			{ desc = "AI Actions", noremap = true, silent = true }
		)
		vim.keymap.set(
			"v",
			"<leader>aa",
			"<cmd>CodeCompanionChat Add<cr>",
			{ desc = "Add to AI Chat", noremap = true, silent = true }
		)

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
