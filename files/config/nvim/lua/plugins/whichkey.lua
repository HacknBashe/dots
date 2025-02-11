return {
	"folke/which-key.nvim",
	config = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
		local wk = require("which-key")
		wk.setup({
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		})
		wk.add({
			{ "<leader>a", group = "Avante/AI" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>f", group = "Find/File" },
			{ "<leader>fd", group = "Find in Directory" },
			{ "<leader>g", group = "Git" },
			{ "<leader>n", group = "Notifications" },
			{ "<leader>q", group = "Quickfix" },
			{ "<leader>t", group = "Tables" },
			{ "<leader>v", group = "View" },
		})
	end,
}
