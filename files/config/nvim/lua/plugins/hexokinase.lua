return {
	"rrethy/vim-hexokinase",
	-- Only enable if go is installed (needed for build)
	enabled = function()
		return require("lib.plugin-deps").check_executable("go", "vim-hexokinase")
	end,
	build = "make hexokinase",
	config = function()
		vim.g.Hexokinase_virtualText = ""
		vim.g.Hexokinase_optInPatterns = "full_hex,rgb,rgba,hsl,hsla"
	end,
}
