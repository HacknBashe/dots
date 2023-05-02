return { -- Git
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
				change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
				delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
				topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
				changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
				untracked = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },

				-- add = { text = "+" },
				-- change = { text = "~" },
				-- delete = { text = "_" },
				-- topdelete = { text = "‾" },
				-- changedelete = { text = "~" },
				-- untracked = { text = "┆" },
			},
		})
	end,
}
