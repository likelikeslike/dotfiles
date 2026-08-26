return {
  "nmac427/guess-indent.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    auto_cmd = true,
    override_editorconfig = true,
  },
  config = function(_, opts)
    require("guess-indent").setup(opts)
    vim.schedule(function()
      require("guess-indent").set_from_buffer(nil, "auto_cmd", true)
    end)
  end,
}
