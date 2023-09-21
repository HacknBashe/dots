return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			-- https://github.com/xdebug/vscode-php-debug/releases
			-- Extract the vsix content
			local dap = require("dap")
			dap.adapters.php = {
				type = "executable",
				-- command = "nodejs",
				command = "node",

				args = {
					os.getenv("HOME")
						.. "/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
				},
			}

			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Listen for xdebug",
					port = "9001",
					log = true,
					pathMappings = {
						["/wayfair/data/codebase/php"] = os.getenv("HOME") .. "/codebase/php",
					},
					-- serverSourceRoot = "/wayfair/data/codebase/php",
					-- localSourceRoot = "~/codebase/php",
				},
			}

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {

						os.getenv("HOME")
							.. "/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}

			dap.configurations.javascript = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}

			vim.keymap.set("n", "<F5>", function()
				dap.continue()
			end)
			vim.keymap.set("n", "<F10>", function()
				dap.step_over()
			end)
			vim.keymap.set("n", "<F11>", function()
				dap.step_into()
			end)
			vim.keymap.set("n", "<F12>", function()
				dap.step_out()
			end)
			vim.keymap.set("n", "<Leader>db", function()
				dap.toggle_breakpoint()
			end)
			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end)
		end,
		dependencies = {
			"williamboman/mason.nvim",
		},
	},

	{
		"rcarriga/nvim-dap-ui",
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<Leader>vd", function()
				dapui.toggle()
			end)
			require("dapui").setup()
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end,
	},
}
