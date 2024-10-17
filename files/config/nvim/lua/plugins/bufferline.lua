return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local function opts(desc)
			return { desc = "Buffer: " .. desc, noremap = true, silent = true, nowait = true }
		end

		-- nnoremap mymap :lua require"bufferline".go_to(num)<CR>
		local bufferline = require("bufferline")
		vim.keymap.set("n", "<leader>bd", ":bd<CR>", opts("Delete Buffer"))
		vim.keymap.set("n", "<leader>bo", ":%bd|e#|bd#<CR>", opts("Delete Other Buffers"))

		vim.keymap.set("n", "<leader>b1", ":lua require('bufferline').go_to(1)<CR>", opts("1"))
		vim.keymap.set("n", "<leader>b2", ":lua require('bufferline').go_to(2)<CR>", opts("2"))
		vim.keymap.set("n", "<leader>b3", ":lua require('bufferline').go_to(3)<CR>", opts("3"))
		vim.keymap.set("n", "<leader>b4", ":lua require('bufferline').go_to(4)<CR>", opts("4"))
		vim.keymap.set("n", "<leader>b5", ":lua require('bufferline').go_to(5)<CR>", opts("5"))

		vim.keymap.set("n", "<leader>bj", ":BufferLineCyclePrev<CR>", opts("Next"))
		vim.keymap.set("n", "<leader>bk", ":BufferLineCycleNext<CR>", opts("Prev"))

		bufferline.setup()
	end,
}
