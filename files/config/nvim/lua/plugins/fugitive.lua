return {
	"tpope/vim-fugitive",
	config = function()
		local function opts(desc)
			return { desc = desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>gf", ":vertical Git <CR>", opts("Git Fugitive"))
		vim.keymap.set("n", "gj", "<cmd>diffget //2<CR>", opts("Grab Left"))
		vim.keymap.set("n", "gf", "<cmd>diffget //3<CR>", opts("Grab Right"))
	end,
}
