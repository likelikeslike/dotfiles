return {
  "NickvanDyke/opencode.nvim",
  cmd = "OpenCode",
  keys = {
    { "<leader>o", "", desc = "+opencode", mode = { "n", "v" } },
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode Ask",
    },
    {
      "<leader>ox",
      function()
        require("opencode").select()
      end,
      mode = { "n", "x" },
      desc = "OpenCode Select",
    },
    {
      "<leader>oo",
      function()
        require("opencode").toggle()
      end,
      mode = { "n", "t" },
      desc = "OpenCode Toggle",
    },
    {
      "<leader>os",
      function()
        return require("opencode").operator("@this ")
      end,
      mode = { "n", "x" },
      desc = "OpenCode Operator",
      expr = true,
    },
    {
      "<leader>ol",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      mode = "n",
      desc = "OpenCode Operator Line",
      expr = true,
    },
  },
  config = function()
    vim.o.autoread = true
  end,
}
