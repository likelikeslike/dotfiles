return {
  {
    "likelikeslike/notebook.nvim",
    event = "BufReadCmd *.ipynb",
    dependencies = {
      { "mason-org/mason.nvim" },
      {
        "3rd/image.nvim",
        event = "BufReadCmd *.ipynb",
        build = false,
        opts = {
          backend = "kitty",
          processor = "magick_cli",
          integrations = {},
        },
      },
    },
    config = function()
      local icons = require("utils.icons")
      require("notebook").setup({
        output_max_height = 20,
        keys = {
          ["i"] = "move_up",
          ["<Up>"] = "move_up",
          ["<Down>"] = "move_down",
          ["k"] = "move_down",
        },
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
            },
          },
        },
        lsp = {
          python = {
            {
              name = "basedpyright",
              -- or use (vim.fn.stdpath("data") .. "/mason/bin/basedpyright-langserver") if not use Mason dependency
              cmd = { vim.fn.exepath("basedpyright-langserver"), "--stdio" },
              settings = {
                basedpyright = {
                  analysis = {
                    typeCheckingMode = "basic",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                  },
                },
                python = {
                  analysis = {
                    inlayHints = {
                      variableTypes = false,
                      functionReturnTypes = false,
                      callArgumentNames = false,
                      parameterTypes = false,
                    },
                  },
                },
              },
            },
            {
              name = "ruff",
              -- or use (vim.fn.stdpath("data") .. "/mason/bin/ruff") if not use Mason dependency
              cmd = { vim.fn.exepath("ruff"), "server" },
              cmd_env = { RUFF_TRACE = "messages" },
              init_options = {
                settings = {
                  logLevel = "error",
                },
              },
              keys = {
                {
                  "<leader>co",
                  function()
                    vim.lsp.buf.code_action({
                      apply = true,
                      context = { only = { "source.organizeImports" }, diagnostics = {} },
                    })
                  end,
                  desc = "Organize Imports",
                },
                {
                  "<leader>cq",
                  function()
                    vim.lsp.buf.code_action({
                      apply = true,
                      context = { only = { "source.fixAll" }, diagnostics = {} },
                    })
                  end,
                  desc = "Fix All",
                },
              },
            },
          },
        },
      })
    end,
  },
}
