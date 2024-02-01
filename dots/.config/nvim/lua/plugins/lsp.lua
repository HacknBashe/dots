local lspconfig = require("lspconfig")
local lspkind = require("lspkind")
local cmp = require("cmp")
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

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
vim.diagnostic.config({
	signs = false,
	virtual_text = true,
})
vim.keymap.set("n", "<leader>vd", function()
	vim.diagnostic.open_float()
end)
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_next()
end)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_prev()
end)

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf, remap = false }

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, opts)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, opts)
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, opts)
		vim.keymap.set("n", "<leader>vca", function()
			vim.lsp.buf.code_action()
		end, opts)
		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, opts)
		vim.keymap.set("n", "<leader>vrn", function()
			vim.lsp.buf.rename()
		end, opts)
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end, opts)
	end,
})

local myborder = cmp.config.window.bordered()
cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{ name = "codeium" },
	},
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol",
			maxwidth = 50,
			ellipsis_char = "...",
			symbol_map = { Codeium = "" },
		}),
	},
	mapping = {
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = "select" }),
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
