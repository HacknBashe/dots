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

local my_theme = {
	normal = {
		a = { fg = "#81a1c1", bg = "NONE", gui = "bold" },
		b = { fg = "#3f4c5c", bg = "NONE" },
		c = { fg = "#abb1bb", bg = "NONE" },
	},
	inactive = {
		a = { fg = "#81a1c1", bg = "NONE" },
		b = { fg = "#7e8188", bg = "NONE", gui = "bold" },
		c = { fg = "#60728a", bg = "NONE" },
	},
	replace = {
		a = { fg = "#bf616a", bg = "NONE", gui = "bold" },
	},
	command = {
		a = { fg = "#ebcb8b", bg = "NONE", gui = "bold" },
	},
	visual = {
		a = { fg = "#b48ead", bg = "NONE", gui = "bold" },
	},
	terminal = {
		a = { fg = "#c9826b", bg = "NONE", gui = "bold" },
	},
	insert = {
		a = { fg = "#a3be8c", bg = "NONE", gui = "bold" },
	},
}

local function codeium()
	return vim.fn["codeium#GetStatusString"]()
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = my_theme,

				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
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
				lualine_x = { "diagnostics", codeium, "filetype" },
				-- lualine_x = { "diagnostics", "require'codeium'.GetStatusString()", "filetype" },
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

-- local auto_theme = {
-- 	normal = {
-- 		a = { bg = "#81a1c1", fg = "#232831", gui = "bold" },
-- 		c = { fg = "#abb1bb", bg = "NONE" },
-- 		b = { fg = "#cdcecf", bg = "#3f4c5c" },
-- 	},
-- 	inactive = {
-- 		c = { fg = "#60728a", bg = "NONE" },
-- 		a = { fg = "#81a1c1", bg = "NONE" },
-- 		b = { bg = "NONE", fg = "#7e8188", gui = "bold" },
-- 	},
-- 	replace = {
-- 		a = { bg = "#bf616a", fg = "#232831", gui = "bold" },
-- 		b = { fg = "#cdcecf", bg = "#523942" },
-- 	},
-- 	command = {
-- 		a = { bg = "#ebcb8b", fg = "#232831", gui = "bold" },
-- 		b = { fg = "#cdcecf", bg = "#5f594c" },
-- 	},
-- 	visual = {
-- 		a = { bg = "#b48ead", fg = "#232831", gui = "bold" },
-- 		b = { fg = "#cdcecf", bg = "#4f4756" },
-- 	},
-- 	terminal = {
-- 		a = { bg = "#c9826b", fg = "#232831", gui = "bold" },
-- 		b = { fg = "#cdcecf", bg = "#554342" },
-- 	},
-- 	insert = {
-- 		a = { bg = "#a3be8c", fg = "#232831", gui = "bold" },
-- 		b = { fg = "#cdcecf", bg = "#49554c" },
-- 	},
-- }
