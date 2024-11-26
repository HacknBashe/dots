return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		vim.keymap.set("n", "<leader>fn", "<cmd> Telescope notify <CR>",{ desc = "Find Notfications", noremap = true, silent = true, nowait = true })

		require("notify").setup({
			timeout = 1000,
		})
	end,
}
