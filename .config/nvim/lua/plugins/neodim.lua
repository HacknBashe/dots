return {
	-- Dim unused code
	"zbirenbaum/neodim",
	config = function()
		require("neodim").setup({
			alpha = 0.7,
			blend_color = "#000000",
			update_in_insert = {
				enable = true,
				delay = 100,
			},
			hide = {
				virtual_text = false,
				signs = false,
				underline = false,
			},
		})
	end,
}
