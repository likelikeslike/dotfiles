return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    config = function()
      local endpoint = vim.env.MINUET_ENDPOINT
      local api_key = vim.env.MINUET_API_KEY
      local model = vim.env.MINUET_MODEL
      if not endpoint or not api_key or not model then
        vim.notify(
          "minuet-ai: MINUET_ENDPOINT, MINUET_API_KEY or MINUET_MODEL not set, skipping setup",
          vim.log.levels.WARN
        )
        return
      end

      require("minuet").setup({
        provider = "openai_compatible",
        n_completions = 1,
        context_window = 4096,
        throttle = 400,
        debounce = 200,
        request_timeout = 8,
        notify = "warn",
        virtualtext = {
          auto_trigger_ft = { "*" },
          keymap = {
            accept = "<M-l>",
            accept_line = "<M-k>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        provider_options = {
          openai_compatible = {
            name = "Minuet",
            end_point = endpoint,
            model = model,
            api_key = "MINUET_API_KEY",
            stream = true,
            optional = {
              max_tokens = 256,
              temperature = 0.2,
              top_p = 0.95,
            },
            transform = {
              function(args)
                args.body.chat_template_kwargs = { thinking = false }
                for _, msg in ipairs(args.body.messages or {}) do
                  if msg.role == "system" then
                    msg.content = msg.content
                      .. "\nCRITICAL: Output raw code only. Never wrap in ``` fences or any markdown. Never explain."
                  end
                end
                return args
              end,
            },
          },
        },
      })

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
          vim.b[buf].minuet_virtual_text_auto_trigger = true
        end
      end
    end,
  },
}
