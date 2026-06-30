local function augroup(name)
  return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Restore cursor position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function(event)
    local exclude_ft = { "gitcommit", "commit", "gitrebase", "xxd", "man", "help" }
    local buf = event.buf
    if vim.tbl_contains(exclude_ft, vim.bo[buf].filetype) or vim.b[buf].large_buf then
      return
    end
    if vim.b[buf].last_loc_restored then
      return
    end
    vim.b[buf].last_loc_restored = true

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local cursor = vim.api.nvim_win_get_cursor(0)
      if cursor[1] ~= 1 or cursor[2] ~= 0 then
        return
      end
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
        local snacks_scroll = package.loaded["snacks.scroll"]
        if snacks_scroll then
          snacks_scroll.disable()
        end
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
        vim.cmd("normal! zz")
        if snacks_scroll then
          vim.defer_fn(function()
            snacks_scroll.enable()
          end, 50)
        end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("two_space_indent"),
  pattern = { "json", "markdown", "sh" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Root detection
require("utils.root").setup()
