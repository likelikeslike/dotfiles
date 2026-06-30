return {
  "dim-inactive",
  virtual = true,
  event = "BufWinEnter",
  config = function()
    local function dim_color(color_hex, factor)
      if not color_hex or color_hex == "" then
        return nil
      end

      factor = factor or 0.6
      local hex = color_hex:gsub("#", "")
      local r = tonumber(hex:sub(1, 2), 16)
      local g = tonumber(hex:sub(3, 4), 16)
      local b = tonumber(hex:sub(5, 6), 16)

      r = math.floor(r * factor)
      g = math.floor(g * factor)
      b = math.floor(b * factor)

      return string.format("#%02x%02x%02x", r, g, b)
    end

    local highlights_to_dim = {
      "Normal",
      "NormalNC",
      "Comment",
      "Keyword",
      "Identifier",
      "String",
      "Parameter",
      "Function",
      "Statement",
      "Type",
      "@variable",
      "@function",
      "@keyword",
      "@string",
      "@number",
      "@constant",
      "@parameter",
      "@property",
      "@type",
      "@operator",
      "@punctuation",
      "@comment",
      "@text",
    }

    local function setup_dim_highlights()
      local all_highlights = vim.list_extend({}, highlights_to_dim)
      for _, hl_name in ipairs(vim.fn.getcompletion("@", "highlight")) do
        table.insert(all_highlights, hl_name)
      end

      for _, hl_name in ipairs(all_highlights) do
        local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
        if hl.fg then
          local fg_hex = string.format("#%06x", hl.fg)
          local dimmed_fg = dim_color(fg_hex, 0.6)

          vim.api.nvim_set_hl(0, "Dim" .. hl_name, {
            fg = dimmed_fg,
            bg = hl.bg and string.format("#%06x", hl.bg) or nil,
            italic = hl.italic,
            bold = hl.bold,
          })
        end
      end
    end

    local function is_normal_buffer(winid)
      winid = winid or 0
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local buftype = vim.bo[bufnr].buftype
      local filetype = vim.bo[bufnr].filetype
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      if buftype ~= "" then
        return false
      end

      local win_config = vim.api.nvim_win_get_config(winid)
      if win_config.relative ~= "" then
        return false
      end

      if filetype:match("^snacks_") then
        return false
      end

      local exclude_filetypes = {
        "neo-tree",
        "NvimTree",
        "qf",
        "help",
        "man",
        "lazy",
        "mason",
        "TelescopePrompt",
      }

      for _, ft in ipairs(exclude_filetypes) do
        if filetype == ft then
          return false
        end
      end

      if bufname:match("^snacks://") then
        return false
      end

      return true
    end

    local function dim_window(winid)
      winid = winid or 0
      if not is_normal_buffer(winid) then
        return
      end

      local map_pairs = {
        "Normal:DimNormal",
        "NormalNC:DimNormalNC",
        "Comment:DimComment",
        "Keyword:DimKeyword",
        "Identifier:DimIdentifier",
        "String:DimString",
        "Parameter:DimParameter",
        "Function:DimFunction",
        "Statement:DimStatement",
        "Type:DimType",
      }
      for _, hl in ipairs(vim.fn.getcompletion("@", "highlight")) do
        table.insert(map_pairs, string.format("%s:Dim%s", hl, hl))
      end

      vim.api.nvim_win_call(winid, function()
        vim.wo.winhighlight = table.concat(map_pairs, ",")
      end)
    end

    local function restore_window(winid)
      winid = winid or 0
      if not is_normal_buffer(winid) then
        return
      end
      vim.api.nvim_win_call(winid, function()
        vim.wo.winhighlight = ""
      end)
    end

    local function is_diff_tab()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.wo[win].diff then
          return true
        end
        local bufnr = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[bufnr].filetype
        local name = vim.api.nvim_buf_get_name(bufnr)
        if ft:match("^[Dd]iffview") or name:match("^diffview://") then
          return true
        end
      end
      return false
    end

    local augroup = vim.api.nvim_create_augroup("DimInactiveWindows", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = augroup,
      callback = setup_dim_highlights,
    })

    local function refresh_dim_state()
      vim.defer_fn(function()
        if is_diff_tab() then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            vim.api.nvim_win_call(win, function()
              vim.wo.winhighlight = ""
            end)
          end
          return
        end

        local current_win = vim.api.nvim_get_current_win()
        if is_normal_buffer(current_win) then
          restore_window(current_win)
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= current_win and is_normal_buffer(win) then
              dim_window(win)
            end
          end
        end
      end, 10)
    end

    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "BufEnter", "TermClose", "FocusGained" }, {
      group = augroup,
      callback = refresh_dim_state,
    })

    vim.defer_fn(setup_dim_highlights, 100)
  end,
}
