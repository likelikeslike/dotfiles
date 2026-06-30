return {
  "folke/noice.nvim",
  event = "UIEnter",
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    views = {
      confirm = {
        size = { width = "auto", height = "auto", max_width = 80 },
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
  keys = {
    { "<leader>sn", "", desc = "+noice" },
    {
      "<S-Enter>",
      function()
        require("noice").redirect(vim.fn.getcmdline())
      end,
      mode = "c",
      desc = "Redirect Cmdline",
    },
    {
      "<leader>snl",
      function()
        require("noice").cmd("last")
      end,
      desc = "Noice Last Message",
    },
    {
      "<leader>snh",
      function()
        require("noice").cmd("history")
      end,
      desc = "Noice History",
    },
    {
      "<leader>sna",
      function()
        require("noice").cmd("all")
      end,
      desc = "Noice All",
    },
    {
      "<leader>snd",
      function()
        require("noice").cmd("dismiss")
      end,
      desc = "Dismiss All",
    },
    {
      "<leader>snt",
      function()
        require("noice").cmd("pick")
      end,
      desc = "Noice Picker (Telescope/FzfLua)",
    },
    {
      "<c-f>",
      function()
        if not require("noice.lsp").scroll(4) then
          return "<c-f>"
        end
      end,
      silent = true,
      expr = true,
      desc = "Scroll Forward",
      mode = { "i", "n", "s" },
    },
    {
      "<c-b>",
      function()
        if not require("noice.lsp").scroll(-4) then
          return "<c-b>"
        end
      end,
      silent = true,
      expr = true,
      desc = "Scroll Backward",
      mode = { "i", "n", "s" },
    },
  },
  config = function(_, opts)
    if vim.o.filetype == "lazy" then
      vim.cmd([[messages clear]])
    end
    require("noice").setup(opts)

    local formatters = require("noice.text.format.formatters")
    local NoiceText = require("noice.text")
    formatters.confirm = function(message, fmt_opts, input)
      if message.kind ~= "confirm" then
        return message:append(input)
      end
      local full = input:content()
      local msg_part, btn_part = full:match("^(.-%?)%s*(.*:)%s*$")
      if not msg_part then
        msg_part, btn_part = full:match("^(.-\n.-)%s+(%[%u%].+:)%s*$")
      end
      if msg_part and btn_part then
        for i, line in ipairs(vim.split(msg_part, "\n", { plain = true })) do
          if i > 1 then
            message:newline()
          end
          message:append(NoiceText(line))
        end
        message:newline()
        message:newline()
        local buttons = vim.split(btn_part:gsub(":$", ""), ", ")
        for b, button in ipairs(buttons) do
          local hl = button:find("%[") and fmt_opts.hl_group.default_choice or fmt_opts.hl_group.choice
          message:append(" " .. button .. " ", hl)
          if b ~= #buttons then
            message:append(" ")
          end
        end
        local padding = math.floor((message:width() - message:last_line():width()) / 2)
        table.insert(message:last_line()._texts, 1, NoiceText((" "):rep(padding)))
      else
        message:append(input)
      end
    end
  end,
}
