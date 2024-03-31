return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		vim.keymap.set("n", "<leader>fn", "<cmd> ObsidianSearch<CR>", { desc = "Find Notes", noremap = true, silent = true, nowait = true })

		vim.opt.conceallevel = 1

		function MarkdownLevel()
			local line = vim.fn.getline(vim.v.lnum)
			if string.match(line, "^# .*$") then
				return ">1"
			elseif string.match(line, "^## .*$") then
				return ">2"
			elseif string.match(line, "^### .*$") then
				return ">3"
			elseif string.match(line, "^#### .*$") then
				return ">4"
			elseif string.match(line, "^##### .*$") then
				return ">5"
			elseif string.match(line, "^###### .*$") then
				return ">6"
			else
				return "="
			end
		end

		vim.api.nvim_command("autocmd BufEnter *.md setlocal foldexpr=v:lua.MarkdownLevel()")
		vim.api.nvim_command("autocmd BufEnter *.md setlocal foldmethod=expr")

		require("obsidian").setup({
			workspaces = {
				{
					name = "notes",
					path = "~/notes",
				},
			},
		})
	end,
}
