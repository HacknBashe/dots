return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			--catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
			transparent_background = true,
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
