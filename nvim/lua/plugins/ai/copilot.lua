return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      copilot_node_command = "node",
      filetypes = {
        markdown = true,
        help = true,
      },
      should_attach = function(bufnr, _)
        if not vim.bo[bufnr].buflisted then
          return false
        end
        local bt = vim.bo[bufnr].buftype
        if bt == "" or bt == "acwrite" then
          return true
        end
        return false
      end,
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local ok, c = pcall(require, "copilot.client")
          if not ok or c.is_disabled() or not c.get() then
            return ""
          end
          local icons = require("utils.icons").kinds
          local ok2, s = pcall(require, "copilot.status")
          if not ok2 then
            return icons.Copilot
          end
          local st = s.data.status
          if st == "Warning" or st == "" then
            return icons.CopilotError
          elseif st == "InProgress" then
            return icons.CopilotPending
          end
          return icons.Copilot
        end,
        cond = function()
          local ok, c = pcall(require, "copilot.client")
          return ok and not c.is_disabled() and c.get() ~= nil
        end,
      })
    end,
  },
}
