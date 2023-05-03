function ColorMyPencils(color)
	color = color or "ron"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	config = function()
	-- 		require("tokyonight").setup({
	-- 			transparent = true,
	-- 		})
	-- 		vim.cmd.colorscheme("tokyonight")
	-- 	end,
	-- },
	-- {
	-- 	"bluz71/vim-nightfly-colors",
	-- 	config = function()
	-- 		-- require("nightfly").setup({})
	-- 		vim.g.nightflyTransparent = true
	-- 		vim.cmd.colorscheme("nightfly")
	-- 	end,
	-- },
	{
		"EdenEast/nightfox.nvim",
		config = function()
			require("nightfox").setup({
				options = {
					transparent = true,
				},
			})
			vim.cmd.colorscheme("nordfox")
		end,
	},
	-- {
	-- 	"AlexvZyl/nordic.nvim",
	-- 	config = function()
	-- 		require("nordic").setup({
	-- 			transparent_bg = true,
	-- 		})
	-- 		-- vim.cmd.colorscheme("nordic")
	-- 		ColorMyPencils("nordic")
	-- 	end,
	-- },
	-- {
	-- 	"rose-pine/neovim",
	-- 	config = function()
	-- 		require("rose-pine").setup({
	-- 			disable_background = true,
	-- 			disable_float_background = true,
	-- 		})
	-- 		vim.cmd.colorscheme("rose-pine")
	-- 	end,
	-- },
	--{
	--	"catppuccin/nvim",
	--	name = "catppuccin",
	--	config = function()
	--		require("catppuccin").setup({
	--			flavour = "mocha",
	--			--catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
	--			transparent_background = true,
	--		})
	--		vim.cmd.colorscheme("catppuccin")
	--	end,
	--},
}
