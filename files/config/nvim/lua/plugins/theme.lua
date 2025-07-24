return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			require("tokyonight").setup({
				transparent = true,
				style = "moon",
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
				on_colors = function(colors)
					colors.fg_gutter = "#636da6"
				end,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
