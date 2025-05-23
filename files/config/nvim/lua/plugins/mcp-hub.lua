return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = "MCPHub",
  build = "npm install -g mcp-hub@latest",
  config = function()
    require("mcphub").setup({
      port = 3000,
      config = vim.fn.expand("~/.config/mcp.json"),
    })

    vim.keymap.set("n", "<leader>vM", ":MCPHub<CR>", { noremap = true, silent = true, desc = "Open MCPHub" })
  end,
}
