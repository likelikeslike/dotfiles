return {
  prompt = " ",
  sources = {
    explorer = require("plugins.snacks.explorer"),
  },
  focus = "input",
  show_delay = 5000,
  limit_live = 10000,
  layout = {
    cycle = true,
    preset = function()
      return vim.o.columns >= 120 and "default" or "vertical"
    end,
  },
  matcher = {
    fuzzy = true,
    smartcase = true,
    ignorecase = true,
    sort_empty = false,
    filename_bonus = true,
    file_pos = true,
    cwd_bonus = false,
    frecency = false,
    history_bonus = false,
  },
  sort = {
    fields = { "score:desc", "#text", "idx" },
  },
  ui_select = true,
  formatters = {
    text = {
      ft = nil,
    },
    file = {
      filename_first = false,

      truncate = "center",
      min_width = 40,
      filename_only = false,
      icon_width = 2,
      git_status_hl = true,
    },
    selected = {
      show_always = false,
      unselected = true,
    },
    severity = {
      icons = true,
      level = false,

      pos = "left",
    },
  },
  previewers = {
    diff = {
      style = "fancy",
      cmd = { "delta" },

      wo = {
        breakindent = true,
        wrap = true,
        linebreak = true,
        showbreak = "",
      },
    },
    git = {
      args = {},
    },
    file = {
      max_size = 1024 * 1024,
      max_line_length = 500,
      ft = nil,
    },
    man_pager = nil,
  },
  jump = {
    jumplist = true,
    tagstack = false,
    reuse_win = false,
    close = true,
    match = false,
  },
  toggles = {
    follow = "f",
    hidden = "h",
    ignored = "i",
    modified = "m",
    regex = { icon = "R", value = false },
  },
  win = {
    input = {
      keys = {
        ["<c-k>"] = { "list_down", mode = "i" },
        ["<c-i>"] = { "list_up", mode = "i" },
        ["<c-l>"] = { "confirm", mode = "i" },
        ["<c-j>"] = false,
        ["<c-w>H"] = false,
        ["<c-w>J"] = "layout_left",
        ["<c-w>K"] = "layout_bottom",
        ["<c-w>I"] = "layout_top",
        ["<c-w>L"] = "layout_right",
        ["k"] = "list_down",
        ["i"] = "list_up",
      },
      b = {
        minipairs_disable = true,
      },
    },
    list = {
      keys = {
        ["l"] = "confirm",
        ["<c-k>"] = { "list_down", mode = "i" },
        ["<c-i>"] = { "list_up", mode = "i" },
        ["<c-w>H"] = false,
        ["<c-w>J"] = "layout_left",
        ["<c-w>K"] = "layout_bottom",
        ["<c-w>I"] = "layout_top",
        ["<c-w>L"] = "layout_right",
        ["h"] = "focus_input",
        ["k"] = "list_down",
        ["i"] = "list_up",
      },
      wo = {
        conceallevel = 2,
        concealcursor = "nvc",
      },
    },
    preview = {
      keys = {
        ["<Esc>"] = "cancel",
        ["q"] = "cancel",
        ["h"] = "focus_input",
        ["<a-w>"] = "cycle_win",
      },
    },
  },
}
