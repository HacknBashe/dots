return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"onsails/lspkind.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			{
				"git@git.hubteam.com:HubSpot/bend.nvim.git",
				enabled = function()
					return vim.fn.hostname() == "JGR2T596J9"
				end,
			},
		},
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lspconfig = require("lspconfig")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			local cmp = require("cmp")
			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
			local isHubspot, bend = pcall(require, "bend")

			if isHubspot then
				bend.setup({})
			end

			require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snippets/" } })

			lspconfig.lua_ls.setup({
				capabilities = lsp_capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = {
								vim.env.VIMRUNTIME,
							},
						},
					},
				},
			})
			lspconfig.jdtls.setup({})
			lspconfig.gopls.setup({})
			lspconfig.ts_ls.setup(isHubspot and {
				init_options = {
					tsserver_path = bend.getTsServerPathForCurrentFile(),
				},
			} or {})
			lspconfig.pyright.setup({})
			lspconfig.nixd.setup({})
			lspconfig.templ.setup({})
			lspconfig.clangd.setup({})

			local dotnet_root = os.getenv("DOTNET_ROOT")
			if dotnet_root then
				lspconfig.csharp_ls.setup({
					capabilities = lsp_capabilities,
					cmd = {
						"env",
						"DOTNET_ROOT=" .. dotnet_root,
						"PATH=" .. dotnet_root .. ":" .. os.getenv("PATH"),
						"csharp-ls",
					},
				})
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local function opts(desc)
						return {
							desc = "LSP: " .. desc,
							buffer = event.buf,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end

					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition()
					end, opts("Go to Definition"))

					vim.keymap.set("n", "K", function()
						vim.lsp.buf.hover({ border = "rounded" })
					end, opts("Hover"))

					vim.keymap.set("n", "<leader>ls", function()
						vim.lsp.buf.document_symbol()
					end, opts("View Document Symbols"))

					vim.keymap.set("n", "<leader>lF", function()
						local loc_list = vim.fn.getloclist(0)
						local pattern = vim.fn.input("Filter pattern: ")
						local new_list = vim.tbl_filter(function(item)
							return item.text:match(pattern)
						end, loc_list)
						vim.fn.setloclist(0, new_list, "r")
						print("Filtered location list with pattern: " .. pattern)
					end, { noremap = true, silent = true, desc = "Filter Location List" })

					vim.keymap.set("n", "<leader>la", function()
						vim.lsp.buf.code_action()
					end, opts("Actions"))

					vim.keymap.set("n", "<leader>lf", function()
						vim.lsp.buf.references()
					end, opts("Find References"))

					vim.keymap.set("n", "<leader>lr", function()
						vim.lsp.buf.rename()
					end, opts("Rename"))

					vim.keymap.set("i", "<C-h>", function()
						vim.lsp.buf.signature_help()
					end, opts("Signature Help"))
				end,
			})

			local myborder = cmp.config.window.bordered()
			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "codeium" },
					{ name = "copilot" },
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						symbol_map = { Codeium = "", Copilot = "" },
					}),
				},
				mapping = {
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-c>"] = cmp.mapping.abort(),
					["<C-n>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1)
						else
							cmp.complete()
						end
					end, { "i", "s" }),
					["<C-p>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = myborder,
					documentation = myborder,
				},
			})
		end,
	},
}
