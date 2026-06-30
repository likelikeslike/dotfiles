local function set_key(filter, spec)
  local Keys = require("lazy.core.handler.keys")
  for _, keys in pairs(Keys.resolve(spec)) do
    local filters = {}
    if keys.has then
      local methods = type(keys.has) == "string" and { keys.has } or keys.has
      for _, method in ipairs(methods) do
        method = method:find("/") and method or ("textDocument/" .. method)
        filters[#filters + 1] = vim.tbl_extend("force", vim.deepcopy(filter), { method = method })
      end
    else
      filters[#filters + 1] = filter
    end

    for _, f in ipairs(filters) do
      local opts = Keys.opts(keys)
      opts.lsp = f
      opts.enabled = keys.enabled
      Snacks.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

local action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      })
    end
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts_extend = { "servers.*.keys" },
    opts = function()
      local icons = require("utils.icons")
      local ret = {
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
        inlay_hints = {
          enabled = false,
          exclude = { "vue" },
        },
        codelens = {
          enabled = false,
        },
        folds = {
          enabled = true,
        },
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        servers = {
          ["*"] = {
            capabilities = {
              workspace = {
                fileOperations = {
                  didRename = true,
                  willRename = true,
                },
              },
            },
            keys = {
              {
                "<leader>ch",
                function()
                  vim.lsp.buf.hover()
                end,
                desc = "Hover",
              },
              {
                "<leader>ck",
                function()
                  vim.lsp.buf.signature_help()
                end,
                desc = "Signature Help",
                has = "signatureHelp",
              },
              {
                "<c-k>",
                function()
                  vim.lsp.buf.signature_help()
                end,
                mode = "i",
                desc = "Signature Help",
                has = "signatureHelp",
              },
              {
                "<leader>ca",
                vim.lsp.buf.code_action,
                desc = "Code Action",
                mode = { "n", "x" },
                has = "codeAction",
              },
              {
                "<leader>cr",
                vim.lsp.buf.rename,
                desc = "Rename",
                has = "rename",
              },
              {
                "<leader>cA",
                action.source,
                desc = "Source Action",
                has = "codeAction",
              },
            },
          },
          basedpyright = {
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
            keys = {
              {
                "<leader>cP",
                function()
                  vim.ui.input({
                    prompt = "Enter new Python project root path: ",
                    default = vim.fn.getcwd(),
                  }, function(input)
                    if input and input ~= "" then
                      local new_root = vim.fn.fnamemodify(input, ":p"):gsub("/$", "")
                      if vim.fn.isdirectory(new_root) == 1 then
                        local clients = vim.lsp.get_clients({ name = "basedpyright" })
                        for _, client in ipairs(clients) do
                          client:stop()
                        end
                        vim.defer_fn(function()
                          vim.lsp.start({
                            name = "basedpyright",
                            cmd = { "basedpyright-langserver", "--stdio" },
                            root_dir = new_root,
                            settings = {
                              basedpyright = {
                                analysis = {
                                  typeCheckingMode = "basic",
                                  autoSearchPaths = true,
                                  useLibraryCodeForTypes = true,
                                  diagnosticMode = "openFilesOnly",
                                },
                              },
                            },
                          })
                          vim.notify("Started basedpyright with root: " .. new_root, vim.log.levels.INFO)
                        end, 500)
                      else
                        vim.notify("Directory does not exist: " .. new_root, vim.log.levels.ERROR)
                      end
                    end
                  end)
                end,
                desc = "Change Python Project Root",
                ft = "python",
              },
            },
          },
          ruff = {
            cmd_env = { RUFF_TRACE = "messages" },
            init_options = {
              settings = {
                logLevel = "error",
              },
            },
            keys = {
              {
                "<leader>co",
                action["source.organizeImports"],
                desc = "Organize Imports",
              },
              {
                "<leader>cq",
                action["source.fixAll"],
                desc = "Fix All",
              },
            },
          },
          pylsp = {
            enabled = false,
          },
          gopls = {
            settings = {
              gopls = {
                gofumpt = true,
                codelenses = {
                  gc_details = false,
                  generate = true,
                  regenerate_cgo = true,
                  run_govulncheck = true,
                  test = true,
                  tidy = true,
                  upgrade_dependency = true,
                  vendor = true,
                },
                hints = {
                  assignVariableTypes = true,
                  compositeLiteralFields = true,
                  compositeLiteralTypes = true,
                  constantValues = true,
                  functionTypeParameters = true,
                  parameterNames = true,
                  rangeVariableTypes = true,
                },
                analyses = {
                  nilness = true,
                  unusedparams = true,
                  unusedwrite = true,
                  useany = true,
                },
                usePlaceholders = true,
                completeUnimported = true,
                staticcheck = true,
                directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                semanticTokens = true,
              },
            },
          },
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                checkOnSave = {
                  command = "clippy",
                },
                procMacro = {
                  enable = true,
                },
                cargo = {
                  features = "all",
                },
              },
            },
          },
          clangd = {
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          },
          taplo = {},
          stylua = { enabled = false },
          lua_ls = {
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = {
                    "vim",
                    "require",
                  },
                },
                workspace = {
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              },
            },
            on_init = function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
                  return
                end
              end
              client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                workspace = {
                  library = { vim.env.VIMRUNTIME },
                },
              })
            end,
          },
        },
        setup = {
          ruff = function()
            Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.definitionProvider = false
              client.server_capabilities.referencesProvider = false
              client.server_capabilities.renameProvider = false
            end)
          end,
          gopls = function()
            Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end)
          end,
          clangd = function()
            Snacks.util.lsp.on({ name = "clangd" }, function(_, client)
              client.server_capabilities.documentFormattingProvider = false
            end)
          end,
        },
      }
      return ret
    end,
    config = vim.schedule_wrap(function(_, opts)
      for server, server_opts in pairs(opts.servers) do
        if type(server_opts) == "table" and server_opts.keys then
          set_key({ name = server ~= "*" and server or nil }, server_opts.keys)
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_clients({ id = args.data.client_id })[1]
          if client and client.server_capabilities.documentSymbolProvider then
            local ok, navic = pcall(require, "nvim-navic")
            if ok then
              navic.attach(client, buffer)
            end
          end
        end,
      })

      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      if opts.folds.enabled then
        Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function()
          if vim.opt.foldmethod:get() == "expr" then
            vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
          end
        end)
      end

      if opts.codelens.enabled and vim.lsp.codelens then
        vim.lsp.codelens.enable(true)
      end

      if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
        opts.diagnostics.virtual_text.prefix = function(diagnostic)
          local icons = require("utils.icons").diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return "●"
        end
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      if opts.servers["*"] then
        vim.lsp.config("*", opts.servers["*"])
      end

      local mason_all = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package) or {}
      local mason_exclude = {}

      local function configure(server)
        if server == "*" then
          return false
        end
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts)
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      require("mason-lspconfig").setup({
        ensure_installed = install,
        automatic_enable = { exclude = mason_exclude },
      })
    end),
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ui = {
        keymaps = {
          install_package = "<M-i>",
        },
      },
      ensure_installed = {
        "stylua",
        "shfmt",
        "ruff",
        "basedpyright",
        "gopls",
        "taplo",
        "clangd",
        "clang-format",
        "ktlint",
        "rust-analyzer",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
