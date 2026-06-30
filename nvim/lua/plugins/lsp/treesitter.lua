return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = function()
      local TS = require("nvim-treesitter")
      if not TS.get_installed then
        vim.notify(
          "Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.",
          vim.log.levels.ERROR
        )
        return
      end
      TS.update(nil, { summary = true })
    end,
    event = { "BufReadPre", "BufNewFile", "BufWinEnter" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      folds = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "diff",
        "go",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "latex",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter")

      setmetatable(require("nvim-treesitter.install"), {
        __newindex = function(_, k)
          if k == "compilers" then
            vim.schedule(function()
              vim.notify(
                "Setting custom compilers for `nvim-treesitter` is no longer supported.\n\nFor more info, see:\n- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
                vim.log.levels.ERROR
              )
            end)
          end
        end,
      })

      if not TS.get_installed then
        return vim.notify("Please use `:Lazy` and update `nvim-treesitter`", vim.log.levels.ERROR)
      elseif type(opts.ensure_installed) ~= "table" then
        return vim.notify("`nvim-treesitter` opts.ensure_installed must be a table", vim.log.levels.ERROR)
      end

      TS.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_config", { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)

          local function enabled(feat)
            local f = opts[feat] or {}
            return f.enable ~= false and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
          end

          if enabled("highlight") then
            pcall(vim.treesitter.start, ev.buf)
          end

          if enabled("indent") then
            vim.bo[ev.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
          end

          if enabled("folds") then
            if vim.opt.foldmethod:get() == "expr" then
              vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter-textobjects")
      if not TS.setup then
        vim.notify("Please use `:Lazy` and update `nvim-treesitter`", vim.log.levels.ERROR)
        return
      end
      TS.setup(opts)

      local function attach(buf)
        if not (vim.tbl_get(opts, "move", "enable")) then
          return
        end
        local moves = vim.tbl_get(opts, "move", "keys") or {}

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == "table" and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub("@", ""):gsub("%..*", "")
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end
            local desc = table.concat(parts, " or ")
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            if not (vim.wo.diff and key:find("[cC]")) then
              vim.keymap.set({ "n", "x", "o" }, key, function()
                require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
              end, {
                buffer = buf,
                desc = desc,
                silent = true,
              })
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_textobjects", { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
}
