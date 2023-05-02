return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		lazy = true,
		config = function()
			-- This is where you modify the settings for lsp-zero
			-- Note: autocompletion settings will not take effect

			-- require('lsp-zero.settings').preset({})

			local lsp = require("lsp-zero")

			lsp.preset("recommended")

			lsp.ensure_installed({
				"tsserver",
				"lua_ls",
			})

			-- Fix Undefined global 'vim'
			lsp.nvim_workspace()

			lsp.set_preferences({
				suggest_lsp_servers = false,
				sign_icons = {
					error = "E",
					warn = "W",
					hint = "H",
					info = "I",
				},
			})

			vim.diagnostic.config({
				virtual_text = true,
			})
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "VonHeikemen/lsp-zero.nvim" },
			{ "L3MON4D3/LuaSnip" },
			{ "onsails/lspkind.nvim" },
		},
		config = function()
			-- Here is where you configure the autocompletion settings.
			-- The arguments for .extend() have the same shape as `manage_nvim_cmp`:
			-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp

			require("lsp-zero.cmp").extend()

			-- -- And you can configure cmp even more, if you want to.
			local cmp = require("cmp")
			local cmp_action = require("lsp-zero.cmp").action()
			local lspkind = require("lspkind")
			local cmp_select = { behavior = cmp.SelectBehavior.Select }
			cmp.setup({
				window = {
					-- completion = "single",
					-- documentation = "single",
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = lspkind.cmp_format(),
				},
				mapping = {
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-f>"] = cmp_action.luasnip_jump_forward(),
					["<C-b>"] = cmp_action.luasnip_jump_backward(),
					-- cmp_mappings["<Tab>"] = nil
					-- cmp_mappings["<S-Tab>"] = nil
				},
			})
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		-- Disable lazy loading because it breaks telescope
		-- cmd = "Lspinfo",
		-- event = { "Bufreadpre", "Bufnewfile" },
		dependencies = {
			{ "VonHeikemen/lsp-zero.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason-lspconfig.nvim" },
			{
				"williamboman/mason.nvim",
				build = function()
					pcall(vim.cmd, "MasonUpdate")
				end,
			},
		},
		config = function()
			-- This is where all the LSP shenanigans will live

			-- local lsp = require('lsp-zero')

			-- lsp.on_attach(function(client, bufnr)
			--   lsp.default_keymaps({buffer = bufnr})
			-- end)

			-- -- (Optional) Configure lua language server for neovim
			-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

			-- lsp.setup()
			--
			local lsp = require("lsp-zero")

			lsp.on_attach(function(_, bufnr)
				local opts = { buffer = bufnr, remap = false }

				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, opts)
				vim.keymap.set("n", "K", function()
					vim.lsp.buf.hover()
				end, opts)
				vim.keymap.set("n", "<leader>vws", function()
					vim.lsp.buf.workspace_symbol()
				end, opts)
				vim.keymap.set("n", "<leader>vd", function()
					vim.diagnostic.open_float()
				end, opts)
				vim.keymap.set("n", "[d", function()
					vim.diagnostic.goto_next()
				end, opts)
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.goto_prev()
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
			end)

			lsp.setup()

			vim.diagnostic.config({
				virtual_text = true,
			})
		end,
	},
}
