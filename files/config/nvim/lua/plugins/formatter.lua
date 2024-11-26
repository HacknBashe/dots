return {
	"mhartington/formatter.nvim",
	config = function()
		local util = require("formatter.util")
		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.DEBUG,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				markdown = {
					require("formatter.filetypes.markdown").prettierd,
				},
				sh = {
					require("formatter.filetypes.sh").shfmt,
				},
				nix = {
					require("formatter.filetypes.nix").alejandra,
				},

				toml = {
					require("formatter.filetypes.toml").prettierd,
				},
				yaml = {
					require("formatter.filetypes.yaml").prettierd,
				},

				go = {
					require("formatter.filetypes.go").gofmt,
				},
				java = {
					require("formatter.filetypes.java").google_java_format,
				},

				html = {
					require("formatter.filetypes.html").prettierd,
				},
				css = {
					require("formatter.filetypes.css").prettierd,
				},
				scss = {
					require("formatter.filetypes.css").prettierd,
				},
				less = {
					require("formatter.filetypes.css").prettierd,
				},
				json = {
					require("formatter.filetypes.json").prettierd,
				},
				jsonc = {
					require("formatter.filetypes.json").prettierd,
				},
				javascript = {
					require("formatter.filetypes.javascript").prettierd,
				},
				javascriptreact = {
					require("formatter.filetypes.javascriptreact").prettierd,
				},
				typescript = {
					require("formatter.filetypes.typescript").prettierd,
				},
				typescriptreact = {
					require("formatter.filetypes.typescriptreact").prettierd,
				},

				python = {
					require("formatter.filetypes.python").black,
				},

				php = {
					require("formatter.filetypes.php").phpcbf,
				},

				-- ["*"] = {
				-- 	require("formatter.filetypes.any").remove_trailing_whitespace,
				-- },
			},
		})

		vim.keymap.set(
			"n",
			"<leader>p",
			":Format<CR>",
			{ desc = "Format File", noremap = true, silent = true, nowait = true }
		)
	end,
}
