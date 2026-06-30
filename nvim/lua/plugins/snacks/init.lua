return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- bigfile = require("plugins.snacks.bigfile"),
    dashboard = require("plugins.snacks.dashboard"),
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = require("plugins.snacks.notifier"),
    picker = require("plugins.snacks.picker"),
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = require("plugins.snacks.terminal"),
    words = { enabled = true },
    lazygit = {
      configure = true,
      config = {
        os = {
          editPreset = "nvim-remote",
        },
      },
    },
  },
  keys = require("plugins.snacks.keymaps"),
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end

        if vim.fn.has("nvim-0.11") == 1 then
          vim._print = function(_, ...)
            dd(...)
          end
        else
          vim.print = _G.dd
        end

        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
