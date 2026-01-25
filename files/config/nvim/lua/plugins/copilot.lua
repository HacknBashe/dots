return {
	{
		"zbirenbaum/copilot.lua",
		-- Only enable if node is installed (needed for runtime)
		enabled = function()
			return require("lib.plugin-deps").check_executable("node", "copilot.lua")
		end,
		cmd = "Copilot",
		event = "VeryLazy",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		-- Only load if copilot.lua is available (implies node is present)
		dependencies = { "zbirenbaum/copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
