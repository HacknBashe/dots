return {
	"rrethy/vim-hexokinase",
	-- TODO: NVIM-NIX This will probably break
	build = "make hexokinase",
	config = function()
		vim.g.Hexokinase_virtualText = ""
		vim.g.Hexokinase_optInPatterns = "full_hex,rgb,rgba,hsl,hsla"
	end,
}
