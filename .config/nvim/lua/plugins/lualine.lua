local case = {
	NORMAL = function()
		return "󰒘"
	end,
	REPLACE = function()
		return "󰞇"
	end,
	INSERT = function()
		return "󰓥"
	end,
	VISUAL = function()
		return "󱡁"
	end,
	COMMAND = function()
		return "󱡄"
	end,
	default = function()
		return "󱡁"
	end,
}

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				-- theme = "auto",
				-- component_separators = { left = "", right = "" },
				sectian_separators = { left = "", right = "" },

				-- component_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },

				component_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },

				-- component_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(input)
							local func = case[input]
							if func then
								return func()
							else
								return case["default"]()
							end
						end,
					},
				},
				lualine_b = { "branch", "diff" },
				lualine_c = { { "filename", path = 1 } },
				-- lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_x = { "diagnostics", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
