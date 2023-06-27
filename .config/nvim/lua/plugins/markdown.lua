return {
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_browser = { [[/Applications/Google\ Chrome.app/]] }
		end,
		ft = { "markdown" },
	},
	"dhruvasagar/vim-table-mode",
}
