return {
	"Exafunction/codeium.vim",
	event = "VeryLazy",
	config = function()
		vim.g.codeium_disable_bindings = 1
		vim.keymap.set("i", "<S-Tab>", function()
			return vim.fn["codeium#Accept"]()
		end, { expr = true })
		vim.keymap.set("i", "<C-Right>", function()
			return vim.fn["codeium#CycleCompletions"](1)
		end, { expr = true })
		vim.keymap.set("i", "<C-Left>", function()
			return vim.fn["codeium#CycleCompletions"](-1)
		end, { expr = true })
	end,
}

