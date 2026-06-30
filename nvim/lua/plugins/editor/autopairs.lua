return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    ts_config = {
      lua = { "string", "source" },
      javascript = { "string", "template_string" },
      java = false,
    },
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    disable_in_macro = false,
    disable_in_visualblock = false,
    disable_in_replace_mode = true,
    ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    enable_moveright = true,
    enable_afterquote = true,
    enable_check_bracket_line = true,
    enable_bracket_in_quote = true,
    enable_abbr = false,
    break_undo = true,
    check_comma = true,
    map_cr = true,
    map_bs = true,
    map_c_h = false,
    map_c_w = false,
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    autopairs.setup(opts)

    local Rule = require("nvim-autopairs.rule")

    autopairs.add_rules({
      Rule(" ", " "):with_pair(function(o)
        local pair = o.line:sub(o.col - 1, o.col)
        return vim.tbl_contains({ "()", "[]", "{}" }, pair)
      end),
      Rule("( ", " )")
        :with_pair(function()
          return false
        end)
        :with_move(function(o)
          return o.prev_char:match(".%)") ~= nil
        end)
        :use_key(")"),
      Rule("{ ", " }")
        :with_pair(function()
          return false
        end)
        :with_move(function(o)
          return o.prev_char:match(".%}") ~= nil
        end)
        :use_key("}"),
      Rule("[ ", " ]")
        :with_pair(function()
          return false
        end)
        :with_move(function(o)
          return o.prev_char:match(".%]") ~= nil
        end)
        :use_key("]"),
    })
  end,
}
