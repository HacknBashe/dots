return {
	"CRAG666/code_runner.nvim",
	config = function()
		vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { noremap = true, silent = false })

		require("code_runner").setup({
			filetype = {
				javascript = "node $fileName",
			},
		})
	end,
}
