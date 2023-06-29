return {
	"Exafunction/codeium.vim",
	event = "VeryLazy",
	config = function()
		vim.g.codeium_disable_bindings = 1
		vim.keymap.set("i", "<S-Tab>", function()
			return vim.fn["codeium#Accept"]()
		end, { expr = true })
	end,
}
