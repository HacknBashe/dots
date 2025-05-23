return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  config = function()
    vim.keymap.set("n", "<leader>fy", "<cmd>Yazi<cr>", { desc = "Yazi", silent = true, noremap = true })
  end,
}
