return {
	-- "nvim-treesitter/nvim-treesitter",
	dir = "/Users/nhackford/.local/share/nvim/nix/nvim-treesitter",
	-- build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/playground",
		"nvim-treesitter/nvim-treesitter-context",
	},
	config = function()
		-- Get the path from the Nix-generated Lua file
		local nix_treesitter_path_file = vim.fn.expand("~/.local/share/nvim/nix/treesitter-path.lua")

		if vim.fn.filereadable(nix_treesitter_path_file) == 1 then
			local nix_treesitter = dofile(nix_treesitter_path_file)
			vim.opt.runtimepath:append(nix_treesitter)
		else
			vim.schedule(function()
				vim.notify(
					"ERROR: Nix treesitter path file not found: " .. nix_treesitter_path_file,
					vim.log.levels.ERROR
				)
			end)
		end

		local autocmd = vim.api.nvim_create_autocmd

		-- autocmd("BufRead", {
		--   pattern = "*rc",
		--   command = "set filetype=sh",
		-- })

		autocmd("BufRead", {
			pattern = "*.conf",
			command = "set filetype=sh",
		})

		autocmd("BufRead", {
			pattern = "*.region",
			command = "set filetype=html",
		})

		autocmd("BufRead", {
			pattern = "*config",
			command = "set filetype=json5",
		})

		vim.api.nvim_set_hl(0, "TreesitterContext", {})
		vim.api.nvim_set_hl(0, "TreesitterContextBottom", {})

		require("nvim-treesitter.configs").setup({
			-- Parsers installed with nix
			auto_install = false,
			highlight = {
				enable = true,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
		})
	end,
}
