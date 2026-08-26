require("full-border"):setup({
  type = ui.Border.ROUNDED,
})

require("starship"):setup({
  -- Hide flags (such as filter, find and search). This is recommended for starship themes which
  -- are intended to go across the entire width of the terminal.
  hide_flags = false, -- Default: false
  -- Whether to place flags after the starship prompt. False means the flags will be placed before the prompt.
  flags_after_prompt = false, -- Default: true
  config_file = "~/.config/yazi/starship.toml",
  -- Custom starship configuration file to use
})

require("git"):setup({})
require("bookmarks"):setup({
  last_directory = { enable = false, persist = false, mode = "dir" },
  persist = "all",
  desc_format = "parent",
  file_pick_mode = "parent",
  custom_desc_input = false,
  show_keys = true,
  notify = {
    enable = false,
    timeout = 1,
    message = {
      new = "New bookmark '<key>' -> '<folder>'",
      delete = "Deleted bookmark in '<key>'",
      delete_all = "Deleted all bookmarks",
    },
  },
})
require("osc7"):setup()
require("root-det"):setup({
  root_markers = {
    ".git",
    ".editorconfig",
    "Makefile",
  },
})
