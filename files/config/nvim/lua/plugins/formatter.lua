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
				sh = {
					require("formatter.filetypes.sh").shfmt,
				},
				nix = {
					require("formatter.filetypes.nix").nixfmt,
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
				typescript = {
					require("formatter.filetypes.typescript").prettierd,
				},
				typescriptreact = {
					require("formatter.filetypes.typescriptreact").prettierd,
				},

				php = {
					require("formatter.filetypes.php").phpcbf,
					function()
						return {
							exe = "phpcbf",
							args = {
								"--standard=/Users/nh470c/codebase/php/non-web/standardscheck/CSNStores",
							},
							stdin = true,
							ignore_exitcode = true,
						}
					end,
				},

				-- ["*"] = {
				-- 	require("formatter.filetypes.any").remove_trailing_whitespace,
				-- },
			},
		})

		vim.keymap.set("n", "<leader>p", ":Format<CR>")
	end,
}
