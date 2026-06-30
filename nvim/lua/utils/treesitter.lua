---@class utils.treesitter
local M = {}

---@param buf? number
---@return boolean
function M.have(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft == "" then
    return false
  end
  local lang = vim.treesitter.language.get_lang(ft)
  if not lang then
    return false
  end
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end
  return parsers.get_parser_configs()[lang] ~= nil
end

---@return string
function M.foldexpr()
  if vim.bo.buftype ~= "" then
    return "0"
  end
  local ok = pcall(vim.treesitter.get_parser)
  return ok and vim.treesitter.foldexpr() or "0"
end

---@return number
function M.indentexpr()
  local ok = pcall(vim.treesitter.get_parser)
  return ok and require("nvim-treesitter").indentexpr() or -1
end

function M.enable_folds()
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.require('utils.treesitter').foldexpr()"
  vim.notify("Treesitter folds enabled", vim.log.levels.INFO, { title = "TS Folds" })
end

function M.disable_folds()
  vim.wo.foldmethod = "indent"
  vim.wo.foldexpr = ""
  vim.notify("Indent folds enabled", vim.log.levels.INFO, { title = "TS Folds" })
end

function M.toggle_folds()
  if vim.wo.foldmethod == "expr" then
    M.disable_folds()
  else
    M.enable_folds()
  end
end

return M
