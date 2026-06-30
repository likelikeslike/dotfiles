return {
  "akinsho/bufferline.nvim",
  event = { "BufReadPre", "BufNewFile", "BufWinEnter" },
  keys = {
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Delete Buffers to the Left" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  },
  opts = {
    options = {
      close_command = function(n)
        Snacks.bufdelete(n)
      end,
      right_mouse_command = function(n)
        Snacks.bufdelete(n)
      end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      separator_style = "slope",
      close_icon = "󰅖",
      buffer_close_icon = "󰅖",
      modified_icon = "●",
      show_buffer_close_icons = true,
      show_close_icon = true,
      diagnostics_indicator = function(_, _, diag)
        local icons = {
          Error = " ",
          Warn = " ",
          Hint = " ",
          Info = " ",
        }
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
        {
          filetype = "snacks_layout_box",
        },
      },
      get_element_icon = function(opts)
        local icons = {
          octo = " ",
          gh = " ",
          ["markdown.gh"] = " ",
        }
        return icons[opts.filetype]
      end,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
  end,
}
