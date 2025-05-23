local statusMap = require("plugins.git-status-map").statusMap

return {
  "chasnovski/mini.nvim",
  lazy = false,
  config = function()
    require("mini.cursorword").setup()
    require("mini.indentscope").setup()
    require("mini.surround").setup()
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })
    require("mini.comment").setup({
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    })
    require("mini.bracketed").setup()

    require("mini.icons").setup()
    if not vim.g.vscode then
      -- require("mini.git").setup()
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = { add = "│", change = "┆", delete = "_" },
          signcolumn = false,
          numhl = true,
        },
      })

      local misc = require("mini.misc")
      misc.setup_restore_cursor()
      vim.keymap.set("n", "<leader>vz", function()
        misc.zoom()
      end, { desc = "Zoom", noremap = true, silent = true, nowait = true })

      local mininotify = require("mini.notify")
      vim.notify = mininotify.make_notify()
      mininotify.setup({
        window = {
          winblend = 0,
        },
      })
      vim.keymap.set("n", "<leader>vn", function()
        mininotify.show_history()
      end, { desc = "View Notification History", noremap = true, silent = true, nowait = true })
      vim.keymap.set("n", "<leader>nd", function()
        mininotify.clear()
      end, { desc = "Dismiss Notifications", noremap = true, silent = true, nowait = true })

      local files = require("mini.files")
      files.setup()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set("n", "<CR>", function()
            files.go_in({ close_on_file = true })
          end, { buffer = buf_id })
        end,
      })
      vim.keymap.set("n", "<leader>ft", function()
        if not files.close() then
          local current_buf_name = vim.api.nvim_buf_get_name(0)
          if current_buf_name and current_buf_name ~= "" and vim.fn.filereadable(current_buf_name) == 1 then
            files.open(current_buf_name)
            files.reveal_cwd()
          else
            files.open(vim.fn.getcwd(), false)
          end
        end
      end, { desc = "File Tree", noremap = true })

      require("mini.pick").setup()
      local extra = require("mini.extra")
      extra.setup()
      vim.keymap.set("n", "<leader>v:", extra.pickers.history, { desc = "View Command History", noremap = true })
      vim.keymap.set("n", "<leader>vH", extra.pickers.hl_groups, { desc = "View Highlights", noremap = true })

      local statusline = require("mini.statusline")
      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })

            local git_info = statusline.section_git({ trunc_width = 75 })
            local branch, status = git_info:match("^(.-)%s*%((..)%s*%)$")
            status = statusMap[status] or { symbol = "?", hlGroup = "NonText" }

            local diff = statusline.section_diff({ trunc_width = 75 })
            local added, changed, removed = "", "", ""
            if diff ~= "" then
              added = diff:match("(%+%d+)") or ""
              changed = diff:match("(~%d+)") or ""
              removed = diff:match("(-%d+)") or ""
            end

            local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
            local errors, warnings, infos, hints = "", "", "", ""
            if diagnostics ~= "" then
              errors = diagnostics:match("(E%d+)") or ""
              warnings = diagnostics:match("(W%d+)") or ""
              infos = diagnostics:match("(I%d+)") or ""
              hints = diagnostics:match("(H%d+)") or ""
            end
            local ai = require("plugins.mini-ai-status")()

            local filename = statusline.section_filename({ trunc_width = 140 })

            local lsp = statusline.section_lsp({ trunc_width = 75 })
            local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
            local search = statusline.section_searchcount({ trunc_width = 75 })

            local mode_map = {
              ["N"] = "󰒘",
              ["I"] = "󰓥",
              ["V"] = "󱡁",
              ["C"] = "󱡄",
            }

            local status_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })

            local git_status_hl = vim.api.nvim_get_hl(0, { name = status.hlGroup })

            local diff_add_hl = vim.api.nvim_get_hl(0, { name = "MiniDiffSignAdd" })
            local changed_hl = vim.api.nvim_get_hl(0, { name = "Changed" })
            local diff_delete_hl = vim.api.nvim_get_hl(0, { name = "MiniDiffSignDelete" })

            local diag_error_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticError" })
            local diag_warn_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" })
            local diag_info_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" })
            local diag_hint_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" })

            vim.api.nvim_set_hl(0, "MiniStatuslineGitStatus", {
              fg = git_status_hl.fg,
              bg = status_hl.bg,
            })

            vim.api.nvim_set_hl(0, "MiniStatuslineDiffAdd", {
              fg = diff_add_hl.fg,
              bg = status_hl.bg,
            })
            vim.api.nvim_set_hl(0, "MiniStatuslineChanged", {
              fg = changed_hl.fg,
              bg = status_hl.bg,
            })
            vim.api.nvim_set_hl(0, "MiniStatuslineDiffDelete", {
              fg = diff_delete_hl.fg,
              bg = status_hl.bg,
            })

            vim.api.nvim_set_hl(0, "MiniStatuslineDiagError", {
              fg = diag_error_hl.fg,
              bg = status_hl.bg,
            })
            vim.api.nvim_set_hl(0, "MiniStatuslineDiagWarn", {
              fg = diag_warn_hl.fg,
              bg = status_hl.bg,
            })
            vim.api.nvim_set_hl(0, "MiniStatuslineDiagInfo", {
              fg = diag_info_hl.fg,
              bg = status_hl.bg,
            })
            vim.api.nvim_set_hl(0, "MiniStatuslineDiagHint", {
              fg = diag_hint_hl.fg,
              bg = status_hl.bg,
            })

            return statusline.combine_groups({
              { hl = mode_hl, strings = { mode_map[mode:sub(1, 1)] } },
              { hl = "MiniStatuslineGitStatus", strings = { branch, status.symbol } },

              { hl = "MiniStatuslineDiffAdd", strings = { added } },
              { hl = "MiniStatuslineChanged", strings = { changed } },
              { hl = "MiniStatuslineDiffDelete", strings = { removed } },

              { hl = "MiniStatuslineDiagError", strings = { errors } },
              { hl = "MiniStatuslineDiagWarn", strings = { warnings } },
              { hl = "MiniStatuslineDiagInfo", strings = { infos } },
              { hl = "MiniStatuslineDiagHint", strings = { hints } },

              "%<", -- Mark general truncate point
              { hl = "Statusline", strings = { filename } },
              "%=", -- End left alignment
              { hl = "Statusline", strings = { ai, lsp, fileinfo } },
              { hl = mode_hl, strings = { search, "%l:%2v" } },
            })
          end,
        },
      })

      local map = require("mini.map")
      map.setup({
        window = { show_integration_count = false, winblend = 0 },
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
          map.gen_integration.diff(),
        },
      })
      vim.keymap.set("n", "<leader>vm", function()
        map.toggle()
      end, { desc = "View Map", noremap = true, silent = true, nowait = true })

      local starter = require("mini.starter")
      starter.setup({
        evaluate_single = true,
        items = {
          starter.sections.builtin_actions(),
          starter.sections.recent_files(9, true),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing("all", { "Builtin actions" }),
          starter.gen_hook.padding(3, 2),
          starter.gen_hook.aligning("center", "center"),
        },
        header = [[
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        footer = " ",
      })

      vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local file_type = vim.bo[buf].filetype

          if file_type == "ministarter" then
            starter.close()
          end
        end,
      })

      vim.keymap.set("n", "<leader>vS", function()
        starter.open()
      end, { desc = "View Starter", noremap = true, silent = true, nowait = true })

      local clue = require("mini.clue")
      vim.o.timeoutlen = 300
      clue.setup({
        window = {
          config = {
            width = 40,
            height = 20,
            border = "rounded",
          },
          delay = 300,
        },

        triggers = {
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          { mode = "i", keys = "<C-x>" },

          { mode = "n", keys = "g" },
          { mode = "n", keys = "z" },
          { mode = "n", keys = "]" },
          { mode = "n", keys = "[" },

          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "n", keys = '"' },

          { mode = "n", keys = "<C-w>" },
        },

        clues = {
          clue.gen_clues.builtin_completion(),
          clue.gen_clues.g(),
          clue.gen_clues.marks(),
          clue.gen_clues.registers(),
          clue.gen_clues.windows(),
          clue.gen_clues.z(),

          { mode = "n", keys = "<Leader>a", desc = "AI Agent" },
          { mode = "n", keys = "<Leader>b", desc = "Buffer" },
          { mode = "n", keys = "<Leader>f", desc = "Find/File" },
          { mode = "n", keys = "<Leader>fd", desc = "Find in Directory" },
          { mode = "n", keys = "<Leader>g", desc = "Git" },
          { mode = "n", keys = "<Leader>n", desc = "Notifications/Notes" },
          { mode = "n", keys = "<Leader>q", desc = "Quickfix" },
          { mode = "n", keys = "<Leader>t", desc = "Tables" },
          { mode = "n", keys = "<Leader>v", desc = "View" },
        },
      })
    end
  end,
}
