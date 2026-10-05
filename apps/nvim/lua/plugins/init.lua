return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mxsdev/nvim-dap-vscode-js",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter",
        adapters = { "pwa-node" },
      })

      for _, lang in ipairs { "typescript", "javascript", "typescriptreact" } do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        width = 32,
        side = "left",
      },
      renderer = {
        highlight_git = "name",         -- Tô màu tên file theo Git
        highlight_diagnostics = "name", -- Tô màu tên file theo Diagnostic (Error / Warn)
        root_folder_label = ":t",
        indent_width = 2,
        indent_markers = {
          enable = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            bottom = "─",
            none = " ",
          },
        },
        icons = {
          show = {
            folder_arrow = false,
            git = false, -- Tắt icon ký hiệu Git (dấu ✗ / x) để màu tên file thể hiện
          },
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
        icons = {
          error = "",
          warning = "",
          hint = "",
          info = "",
        },
      },
    },
  },
  {
    "keaising/im-select.nvim",
    event = "InsertEnter",
    config = function()
      require("im_select").setup({
        -- Mã bộ gõ Tiếng Anh mặc định của IBus
        default_im_select = "xkb:us::eng",

        -- Tự động trả về Tiếng Anh khi thoát Insert Mode hoặc chuyển cửa sổ
        set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
        set_previous_events = { "InsertEnter" },
      })
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup", -- popup nổi ở giữa màn hình
      },
      messages = {
        enabled = true,
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      lsp = {
        progress = {
          enabled = false, -- tránh xung đột lsp progress của NvChad
        },
        hover = {
          enabled = true,
          silent = true,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, -- search popup nổi
        command_palette = true, -- gom cmdline & popupmenu vào giữa màn hình
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true, -- BẬT VIỀN NỔI BẬT CHO HOVER DOCS
      },
      views = {
        hover = {
          border = {
            style = "rounded",
            padding = { 0, 2 },
          },
          position = { row = 2, col = 0 },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
              FloatBorder = "FloatBorder",
            },
          },
        },
      },
    },
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require("neoscroll").setup({
        mappings = { "<C-u>", "<C-d>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" }, -- Bỏ <C-b> để giữ phím mở sidebar giống VS Code
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "quadratic", -- hiệu ứng cuộn mượt (smooth easing)
        pre_hook = nil,
        post_hook = nil,
      })
    end,
  },
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      layout = {
        max_width = { 40, 0.25 },
        width = nil,
        min_width = 25,
        default_direction = "prefer_right",
      },
      show_guides = true,
      filter_kind = false,
      attach_mode = "global",
    },
  },
}