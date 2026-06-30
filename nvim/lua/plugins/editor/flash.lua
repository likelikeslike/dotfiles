return {
  "folke/flash.nvim",
  vscode = true,
  opts = {
    label = {
      rainbow = {
        enabled = true,
        shade = 5,
      },
    },
    mode = {
      char = {
        jump_labels = true,
      },
    },
  },
  event = "BufWinEnter",
  keys = {
    {
      "<A-s>",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "<A-S>",
      mode = { "n", "o", "x" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
    {
      "<c-space>",
      mode = { "n", "o", "x" },
      function()
        require("flash").treesitter({
          actions = {
            ["<c-space>"] = "next",
            ["<BS>"] = "prev",
          },
        })
      end,
      desc = "Treesitter Incremental Selection",
    },
  },
}
