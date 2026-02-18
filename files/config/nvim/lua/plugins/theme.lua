return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			-- Load night colors before setup to avoid recursion
			local night = require("tokyonight.colors").setup({ style = "night" })

			require("tokyonight").setup({
				transparent = true,
				style = "moon",
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
				on_colors = function(colors)
					colors.fg_gutter = colors.comment
					colors.bg = night.bg
					colors.bg_dark = night.bg_dark
				end,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
