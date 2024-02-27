return {
	"tpope/vim-fugitive",
	config = function()
		local function opts(desc)
			return { desc = desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>gg", ":vertical Git <CR>", opts("Git Fugitive"))
	end,
}
