return {
	"ThePrimeagen/harpoon",
	event = "VimEnter",
	config = function()
		local harpoon = require("harpoon")
		harpoon.setup()

		local function opts(desc)
			return { desc = "Harpoon: " .. desc, noremap = true, silent = true, nowait = true }
		end

		vim.keymap.set("n", "<leader>H", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, opts("View Harpoon List"))

		vim.keymap.set("n", "<leader>h", function()
			harpoon:list():add()
		end, opts("Harpoon File"))

		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, opts("Go to 1"))
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, opts("Go to 2"))
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, opts("Go to 3"))
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, opts("Go to 4"))
		vim.keymap.set("n", "<leader>5", function()
			harpoon:list():select(4)
		end, opts("Go to 5"))
		vim.keymap.set("n", "<leader>6", function()
			harpoon:list():select(4)
		end, opts("Go to 6"))
		vim.keymap.set("n", "<leader>7", function()
			harpoon:list():select(4)
		end, opts("Go to 7"))
		vim.keymap.set("n", "<leader>8", function()
			harpoon:list():select(4)
		end, opts("Go to 8"))
		vim.keymap.set("n", "<leader>9", function()
			harpoon:list():select(4)
		end, opts("Go to 9"))
		vim.keymap.set("n", "<leader>0", function()
			harpoon:list():select(4)
		end, opts("Go to 0"))
	end,
}
