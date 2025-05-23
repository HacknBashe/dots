return {
  "folke/trouble.nvim",
  config = function()
    vim.diagnostic.config({
      signs = true,
      virtual_text = false,
    })

    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "View Diagnostic", noremap = true })
    vim.keymap.set(
      "n",
      "<leader>vD",
      "<cmd>Trouble diagnostics toggle<cr>",
      { desc = "View Diagnostic Quickfix List", silent = true, noremap = true }
    )

    require("trouble").setup()
  end,
}
