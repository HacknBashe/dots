return {
  "ThePrimeagen/harpoon",
  event = "VimEnter",
  config = function()
    local harpoon = require("harpoon")
    harpoon.setup()

    local function opts(desc)
      return { desc = desc, noremap = true, silent = true, nowait = true }
    end

    vim.keymap.set("n", "<leader>vh", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, opts("View Harpoon List"))

    vim.keymap.set("n", "<leader>h", function()
      harpoon:list():add()
    end, opts("Harpoon File"))

    vim.keymap.set("n", "<leader>1", function()
      harpoon:list():select(1)
    end, opts("Open Harpoon File 1"))
    vim.keymap.set("n", "<leader>2", function()
      harpoon:list():select(2)
    end, opts("Open Harpoon File 2"))
    vim.keymap.set("n", "<leader>3", function()
      harpoon:list():select(3)
    end, opts("Open Harpoon File 3"))
    vim.keymap.set("n", "<leader>4", function()
      harpoon:list():select(4)
    end, opts("Open Harpoon File 4"))
    vim.keymap.set("n", "<leader>5", function()
      harpoon:list():select(5)
    end, opts("Open Harpoon File 5"))
  end,
}
