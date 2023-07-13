return {
	-- gc to comment
	"tpope/vim-commentary",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "nix",
			command = "setlocal commentstring=#%s"
		})
	end
}
