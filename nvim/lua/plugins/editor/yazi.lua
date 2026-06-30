return {
  "mikavilpas/yazi.nvim",
  version = "*",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    { "<leader>y", "", desc = "+yazi", mode = { "n", "v" } },
    {
      "<leader>yy",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      "<leader>yw",
      function()
        require("yazi").yazi(nil, require("utils.root").get())
      end,
      desc = "Open yazi at project root",
    },
    {
      "<leader>yR",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi at nvim's cwd",
    },
    {
      "<leader>yr",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
    {
      "<leader>yc",
      function()
        local current = vim.api.nvim_buf_get_name(0)
        if current == "" then
          vim.notify("No file in current buffer", vim.log.levels.WARN)
          return
        end
        require("yazi").yazi({
          open_file_function = function(target)
            vim.cmd("tabnew " .. vim.fn.fnameescape(current))
            vim.cmd("diffthis")
            vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(target))
          end,
        })
      end,
      desc = "Diff: Compare with file",
    },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
      open_file_in_horizontal_split = "<c-h>",
    },
    integrations = {
      grep_in_directory = "snacks.picker",
      grep_in_selected_files = "snacks.picker",
    },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
