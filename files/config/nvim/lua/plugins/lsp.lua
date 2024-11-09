local lspconfig = require("lspconfig")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
local cmp = require("cmp")
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

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
lspconfig.ts_ls.setup({})
lspconfig.pyright.setup({})
lspconfig.nixd.setup({})
lspconfig.templ.setup({})

vim.diagnostic.config({
	signs = false,
	virtual_text = true,
})
vim.keymap.set("n", "<leader>vd", function()
	vim.diagnostic.open_float()
end, { desc = "View diagnostic", noremap = true })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_next()
end, { desc = "Next diagnostic", noremap = true })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_prev()
end, { desc = "Prev diagnostic", noremap = true })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local function opts(desc)
			return { desc = "LSP: " .. desc, buffer = event.buf, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, opts("Go to Definition"))
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, opts("Hover"))
		vim.keymap.set("n", "<leader>vw", function()
			vim.lsp.buf.workspace_symbol()
		end, opts("View Workspace Symbol"))
		vim.keymap.set("n", "<leader>vc", function()
			vim.lsp.buf.code_action()
		end, opts("View Code Actions"))
		vim.keymap.set("n", "<leader>vr", function()
			vim.lsp.buf.references()
		end, opts("View References"))
		vim.keymap.set("n", "<leader>vn", function()
			vim.lsp.buf.rename()
		end, opts("Visual Rename"))
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
