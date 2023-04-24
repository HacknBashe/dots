function ColorMyPencils(color)
	require("catppuccin").setup({
		flavour = "mocha",
		transparent_background = true,
		--catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
	})

	-- color = color or "tokyonight"
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)

	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()
