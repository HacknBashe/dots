-- Show diagnostics
return {
	"folke/trouble.nvim",
	config = function()
		vim.keymap.set("n", "<leader>vq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })

		require("trouble").setup({
			icons = false,
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		})
	end,
}
