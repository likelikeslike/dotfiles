local copilot_status = {}

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.schedule(function()
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/copilot-language-server"
        if vim.uv.fs_stat(mason_bin) then
          return
        end
        local ok, mr = pcall(require, "mason-registry")
        if not ok then
          return
        end
        mr.refresh(function()
          local pkg = mr.get_package("copilot-language-server")
          if not pkg then
            return
          end
          if pkg:is_installed() then
            vim.notify(
              "Reinstalling broken copilot-language-server...",
              vim.log.levels.WARN,
              { title = "copilot-native" }
            )
            pkg:install({ force = true }):once(
              "closed",
              vim.schedule_wrap(function()
                vim.notify("copilot-language-server reinstalled", vim.log.levels.INFO, { title = "copilot-native" })
              end)
            )
          else
            vim.notify(
              "Installing copilot-language-server via Mason...",
              vim.log.levels.INFO,
              { title = "copilot-native" }
            )
            pkg:install():once(
              "closed",
              vim.schedule_wrap(function()
                vim.notify("copilot-language-server installed", vim.log.levels.INFO, { title = "copilot-native" })
              end)
            )
          end
        end)
      end)
    end,
    opts = {
      servers = {
        copilot = {
          mason = false,
          keys = {
            {
              "<M-]>",
              function()
                vim.lsp.inline_completion.select({ count = 1 })
              end,
              desc = "Next Copilot Suggestion",
              mode = { "i", "n" },
            },
            {
              "<M-[>",
              function()
                vim.lsp.inline_completion.select({ count = -1 })
              end,
              desc = "Prev Copilot Suggestion",
              mode = { "i", "n" },
            },
            {
              "<M-l>",
              function()
                local ok, accepted = pcall(vim.lsp.inline_completion.get)
                if not ok or not accepted then
                  return "<M-l>"
                end
              end,
              desc = "Accept Copilot inline completion",
              mode = "i",
              expr = true,
            },
          },
        },
      },
      setup = {
        copilot = function()
          vim.schedule(function()
            vim.lsp.inline_completion.enable()
          end)
          vim.lsp.config("copilot", {
            handlers = {
              didChangeStatus = function(err, res, ctx)
                if err then
                  return
                end
                copilot_status[ctx.client_id] = res.kind ~= "Normal" and "error" or res.busy and "pending" or "ok"
                rawset(vim.g, "copilot_native_status", copilot_status)
              end,
            },
          })
        end,
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
          if #clients == 0 then
            return ""
          end
          local icons = require("utils.icons").kinds
          local st = rawget(vim.g, "copilot_native_status") or {}
          local s = st[clients[1].id]
          if not s or s == "error" then
            return icons.CopilotError
          elseif s == "pending" then
            return icons.CopilotPending
          end
          return icons.Copilot
        end,
        cond = function()
          return #vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) > 0
        end,
      })
    end,
  },
}
