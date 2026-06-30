return {
  finder = "explorer",
  sort = { fields = { "sort" } },
  supports_live = true,
  tree = true,
  watch = true,
  diagnostics = true,
  diagnostics_open = false,
  git_status = true,
  git_status_open = false,
  git_untracked = true,
  follow_file = true,
  focus = "list",
  auto_close = false,
  jump = { close = false },
  layout = { preset = "sidebar", preview = false },
  formatters = {
    file = { filename_only = true },
    severity = { pos = "right" },
  },
  matcher = { sort_empty = false, fuzzy = false },
  config = function(opts)
    return require("snacks.picker.source.explorer").setup(opts)
  end,
  win = {
    list = {
      keys = {
        ["i"] = "list_up",
        ["<c-j>"] = false,
        ["k"] = "list_down",
        ["j"] = "explorer_close",
        ["l"] = "confirm",
        ["h"] = "focus_input",
      },
    },
    input = {
      keys = {
        ["l"] = "confirm",
        ["j"] = "explorer_close",
        ["<c-j>"] = { "explorer_close", mode = "i" },
      },
    },
  },
}
