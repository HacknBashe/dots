return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		-- nnoremap mymap :lua require"bufferline".go_to(num)<CR>
		local bufferline = require("bufferline")
		vim.keymap.set("n", "<leader>bd", ":bd")

		vim.keymap.set("n", "<leader>b1", ":lua require('bufferline').go_to(1)<CR>")
		vim.keymap.set("n", "<leader>b2", ":lua require('bufferline').go_to(2)<CR>")
		vim.keymap.set("n", "<leader>b3", ":lua require('bufferline').go_to(3)<CR>")
		vim.keymap.set("n", "<leader>b4", ":lua require('bufferline').go_to(4)<CR>")
		vim.keymap.set("n", "<leader>b5", ":lua require('bufferline').go_to(5)<CR>")

		vim.keymap.set("n", "<leader>bh", ":BufferLineCyclePrev<CR>")
		vim.keymap.set("n", "<leader>bl", ":BufferLineCycleNext<CR>")

		bufferline.setup()
	end,
}
