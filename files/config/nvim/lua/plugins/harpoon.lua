return {
	"ThePrimeagen/harpoon",
	event = "VimEnter",
	config = function()
		local harpoon = require("harpoon")
		harpoon.setup()

		local function opts(desc)
			return { desc = "Harpoon: " .. desc, noremap = true, silent = true, nowait = true }
		end

		-- local conf = require("telescope.config").values
		-- local function toggle_telescope(harpoon_files)
		-- 	local file_paths = {}
		-- 	for _, item in ipairs(harpoon_files.items) do
		-- 		table.insert(file_paths, item.value)
		-- 	end

		-- 	require("telescope.pickers")
		-- 		.new({}, {
		-- 			prompt_title = "Harpoon",
		-- 			finder = require("telescope.finders").new_table({
		-- 				results = file_paths,
		-- 			}),
		-- 			previewer = conf.file_previewer({}),
		-- 			sorter = conf.generic_sorter({}),
		-- 		})
		-- 		:find()
		-- end
		-- vim.keymap.set("n", "<leader>h", function()
		-- 	toggle_telescope(harpoon:list())
		-- end, { desc = "Open harpoon window" })

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():append()
		end, opts("Append"))
		vim.keymap.set("n", "<leader>h", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, opts("Quick Menu"))

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
	end,
}
