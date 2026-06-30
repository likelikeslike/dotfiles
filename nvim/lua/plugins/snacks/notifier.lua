return {
  timeout = 3000,
  width = { min = 40, max = 0.4 },
  height = { min = 1, max = 0.6 },
  margin = { top = 0, right = 1, bottom = 0 },
  padding = true,
  gap = 5,
  sort = { "level", "added" },
  level = vim.log.levels.TRACE,
  icons = {
    error = " ",
    warn = " ",
    info = " ",
    debug = " ",
    trace = " ",
  },
  keep = function(notif)
    return vim.fn.getcmdpos() > 0
  end,
  style = "compact",
  top_down = true,
  date_format = "%R",
  more_format = " ↓ %d lines ",
  refresh = 50,
}
