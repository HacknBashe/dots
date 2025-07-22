return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
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
			legacy_commands = false,
			ui = { enable = false },
			workspaces = {
				{
					name = "notes",
					path = "~/notes",
				},
			},
		})

		vim.keymap.set("n", "<leader>nt", function()
			vim.cmd("Obsidian today")
			vim.defer_fn(function()
				vim.cmd("filetype detect")
			end, 100)
		end, { desc = "Obsidian Today" })
		vim.keymap.set("n", "<leader>nT", function()
			vim.cmd("Obsidian tomorrow")
			vim.defer_fn(function()
				vim.cmd("filetype detect")
			end, 100)
		end, { desc = "Obsidian Tomorrow" })
		vim.keymap.set("n", "<leader>ny", function()
			vim.cmd("Obsidian yesterday")
			vim.defer_fn(function()
				vim.cmd("filetype detect")
			end, 100)
		end, { desc = "Obsidian Yesterday" })
	end,
}
