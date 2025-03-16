return {
	"debugloop/telescope-undo.nvim",
	dependencies = {
		{
			"nvim-telescope/telescope.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
	},
	config = function()
		require("telescope").load_extension("undo")
		vim.keymap.set("n", "<leader>vu", "<cmd>Telescope undo<cr>", { desc = "undo history" })
	end,
}
