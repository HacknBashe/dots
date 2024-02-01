return {
	preview = {
		"iamcco/markdown-preview.nvim",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		cmd = {
			"MarkdownPreview",
			"MarkdownPreviewStop",
			"MarkdownPreviewToggle",
		},
		event = "BufRead",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	"dhruvasagar/vim-table-mode",
	toc = {
		"mzlogin/vim-markdown-toc",
		config = function()
			vim.g["vmt_list_item_char"] = "-"
			vim.g["vmt_fence_text"] = "TOC"
			vim.g["vmt_fence_closing_text"] = "/TOC"
		end,
	},
}
