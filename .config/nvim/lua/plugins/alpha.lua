return {
	"goolord/alpha-nvim",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		local theta = require("alpha.themes.theta")

		local header = {
			type = "text",
			val = {
				[[⠀                                     ⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⣶⣦⣄⠀⠀⠀⠀⠀⠀⠀]],
				[[⠀                                   ⠀ ⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀]],
				[[⠀                                   ⠀ ⠀⡠⠴⣤⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣤⠦⢄⠀]],
				[[⠀                                   ⠀ ⠀⠃⢀⣾⠇⡈⣿⣿⣿⣿⣿⣿⣿⣿⠁⠸⣷⡀⠘⠁]],
				[[⠀ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   ⠀⠀     _⠀⠀⠀⠀        ⠀⢀⣾⠏⢠⠇⢘⣿⣿⣿⣿⣿⣿⡃⠸⡄⠹⣷⡀⠀]],
				[[                        (_)        ⠀⠀ ⠀⣾⣿⠀⣿⣄⡨⣏⣻⣿⣿⣟⣹⣃⣠⡷⢀⣿⣷⠀]],
				[[   _ __   ___  _____   ___ _ __ ___⠀⠀ ⠀⢿⣿⣷⣬⢽⢮⡿⣿⣿⣿⣿⢿⡵⡭⣥⣾⣿⡿⠀]],
				[[  | '_ \ / _ \/ _ \ \ / | | '_ ` _ \  ⠀⣠⣭⣶⡎⡷⣏⣽⣿⣿⢿⣿⣧⡻⣾⣶⣮⣭⣄⠀]],
				[[  | | | |  __| (_) \ V /| | | | | | | ⠀⣿⣿⣩⢔⣽⣿⠿⢛⠁⢈⡛⢿⣿⣶⡁⣩⣿⣿⠀]],
				[[  |_| |_|\___|\___/ \_/ |_|_| |_| |_| ⠀⠙⠛⠟⢸⣿⣏⠀⠈⡷⢺⠀⠀⣹⣿⡇⠻⠛⠉⠀]],
				[[       ⠀⠀⠀⠀⠀                          ⠀⠀⠀⠀⠀⠛⠿⠷⠟⠁⠈⠻⠾⠿⠛⠀⠀⠀⠀⠀]],
			},
			opts = {
				position = "center",
				hl = "Constant",
			},
		}

		local section_mru = {
			type = "group",
			val = {
				{
					type = "text",
					val = "Recent files",
					opts = {
						hl = "SpecialComment",
						shrink_margin = false,
						position = "center",
					},
				},
				{ type = "padding", val = 1 },
				{
					type = "group",
					val = function()
						return { theta.mru(0, vim.fn.getcwd()) }
					end,
					opts = { shrink_margin = false },
				},
			},
		}

		local buttons = {
			type = "group",
			val = {
				{ type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
				{ type = "padding", val = 1 },
				dashboard.button("e", "  New file", "<cmd>ene <CR>"),
				dashboard.button("SPC f t", "󰙅  File tree"),
				dashboard.button("SPC f f", "󰱽  Find file"),
				dashboard.button("SPC f r", "  Recently opened files"),
				dashboard.button("SPC f s", "󱎸  Find string"),
				dashboard.button("SPC f h", "󰘥  Find help"),
			},
			position = "center",
		}

		theta.config.layout = {
			header,
			{ type = "padding", val = 1 },
			section_mru,
			{ type = "padding", val = 1 },
			buttons,
		}

		vim.keymap.set("n", "<leader>va", ":Alpha <CR>", {}, "view alpha")

		require("alpha").setup(theta.config)
	end,
}
