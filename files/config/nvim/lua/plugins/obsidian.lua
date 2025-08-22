return {
	"epwalsh/obsidian.nvim",
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
			vim.cmd("ObsidianToday")
			vim.defer_fn(function()
				vim.cmd("filetype detect")
			end, 100)
		end, { desc = "Obsidian Today" })
		vim.keymap.set("n", "<leader>nT", function()
			vim.cmd("ObsidianTomorrow")
			vim.defer_fn(function()
				vim.cmd("filetype detect")
			end, 100)
		end, { desc = "Obsidian Tomorrow" })
		vim.keymap.set("n", "<leader>ny", function()
			vim.cmd("ObsidianYesterday")
			vim.defer_fn(function()
				vim.cmd("filetype detect")
			end, 100)
		end, { desc = "Obsidian Yesterday" })

		-- Add task toggle for markdown files outside Obsidian workspace
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				local obsidian_workspace = vim.fn.expand("~/notes")
				local current_file = vim.fn.expand("%:p")
				
				-- Only add keymap if we're NOT in the Obsidian workspace
				if not vim.startswith(current_file, obsidian_workspace) then
					vim.keymap.set("n", "<CR>", function()
						return require("obsidian").util.smart_action()
					end, { buffer = true, expr = true, desc = "Toggle task checkbox" })
				end
			end,
		})
	end,
}
