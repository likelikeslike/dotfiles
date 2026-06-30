return {
  {
    "saghen/blink.cmp",
    version = not vim.g.lazyvim_blink_main and "1.*",
    build = vim.g.lazyvim_blink_main and "cargo build --release",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.default",
    },
    dependencies = {
      "rafamadriz/friendly-snippets",
      "fang2hou/blink-copilot",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      snippets = {
        preset = "default",
      },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = false,
        },
        list = {
          selection = {
            preselect = function(ctx)
              return not require("blink.cmp").snippet_active({ direction = 1 })
            end,
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
            opts = {
              max_completions = 3,
              max_attempts = 4,
              kind_name = "Copilot",
              kind_icon = "",
              debounce = 200,
              auto_refresh = {
                backward = true,
                forward = true,
              },
            },
          },
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },
      keymap = {
        preset = "super-tab",
        ["<C-y>"] = { "select_and_accept" },
      },
    },
    config = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons =
        vim.tbl_extend("force", opts.appearance.kind_icons or {}, require("utils.icons").kinds)

      for _, provider in pairs(opts.sources.providers or {}) do
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          CompletionItemKind[provider.kind] = kind_idx

          local transform_items = provider.transform_items
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
              item.kind_icon = require("utils.icons").kinds[item.kind_name] or item.kind_icon or nil
            end
            return items
          end

          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },
}
