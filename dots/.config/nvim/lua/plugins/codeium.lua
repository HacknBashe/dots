return {
	"Exafunction/codeium.vim",
	event = "VeryLazy",
	config = function()
		require("codeium").setup()
	end,
}
