return {
	-- Tmux
	"christoomey/vim-tmux-navigator",
	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",
	-- gc to comment
	"tpope/vim-commentary",
	-- sa to surround
	"machakann/vim-sandwich",
	-- muticursor
	"mg979/vim-visual-multi",
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_browser = { [[/Applications/Google\ Chrome.app/]] }
		end,
		ft = { "markdown" },
	},
}
