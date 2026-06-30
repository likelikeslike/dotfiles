return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local tokyonight = require("tokyonight")

    tokyonight.setup({
      dim_inactive = true,
      transparent = true,
      on_highlights = function(hl, c)
        hl.BufferLineSeparator = { fg = c.bg_dark, bg = "NONE" }
        hl.BufferLineSeparatorVisible = { fg = c.bg_dark, bg = "NONE" }
        hl.BufferLineSeparatorSelected = { fg = c.bg_dark, bg = "NONE" }
        hl.BufferLineFill = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
        hl.FloatBorder = { bg = "NONE" }
        hl.FloatTitle = { bg = "NONE" }
        hl.SnacksPicker = { bg = "NONE" }
        hl.SnacksPickerList = { bg = "NONE" }
        hl.SnacksPickerPreview = { bg = "NONE" }
        hl.SnacksPickerInput = { bg = "NONE" }
        hl.SnacksPickerBorder = { fg = c.border_highlight, bg = "NONE" }

        hl.DiffviewFilePanelTitle = { fg = c.magenta, bg = "NONE" }
        hl.DiffviewFilePanel = { fg = c.magenta, bg = "NONE" }
        hl.DiffviewFilePanelCounter = { fg = c.purple, bg = "NONE" }
        hl.DiffviewFilePanelRootPath = { fg = c.dark5, bg = "NONE" }

        hl.BufferLineTab = { fg = c.dark5, bg = "NONE" }
        hl.BufferLineTabSelected = { fg = c.blue, bg = "NONE" }
        hl.BufferLineTabSeparator = { fg = c.bg_dark, bg = "NONE" }
        hl.BufferLineTabSeparatorSelected = { fg = c.bg_dark, bg = "NONE" }
        hl.BufferLineTabClose = { fg = c.dark5, bg = "NONE" }
      end,
    })
    vim.cmd("colorscheme tokyonight")
  end,
}
