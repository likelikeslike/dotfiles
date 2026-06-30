return {
  pane_gap = 10,
  sections = {
    {
      section = "terminal",
      cmd = "pkm-scripts -r --exclude-games yellow,gold,crystal,red-blue,silver --no-name && sleep 99",
      height = 20,
      ttl = 0,
      padding = 1,
    },
    { section = "header", padding = 1, pane = 2 },
    { section = "keys", gap = 1, padding = 1, pane = 2 },
    { pane = 3, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 5 },
    { pane = 3, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    { section = "startup", padding = 1, pane = 2 },
  },
}
