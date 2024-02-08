return {
	-- gc to comment
	"tpope/vim-commentary",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "nix",
			command = "setlocal commentstring=#%s"
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "hocon",
			command = "setlocal commentstring=#%s"
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "json5",
			command = "setlocal commentstring=//%s"
		})
	end
}
