---@class utils.format
local M = {}

---@param buf? number
---@return boolean
function M.enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat
  if baf ~= nil then
    return baf
  end
  return gaf == nil or gaf
end

---@param buf? number
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local buf_status = baf == nil and "inherit" or (baf and "enabled" or "disabled")
  local msg = string.format("Global: %s | Buffer: %s", gaf and "on" or "off", buf_status)
  vim.notify(msg, vim.log.levels.INFO, { title = "Autoformat" })
end

---@param buf? boolean
function M.toggle(buf)
  if buf then
    vim.b.autoformat = not vim.b.autoformat
  else
    vim.g.autoformat = not (vim.g.autoformat ~= false)
  end
  M.info()
end

---@param enable? boolean
---@param buf? boolean
function M.enable(enable, buf)
  enable = enable == nil and true or enable
  if buf then
    vim.b.autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
  M.info()
end

function M.save_no_format()
  local buf = vim.api.nvim_get_current_buf()
  vim.b[buf].autoformat = false
  vim.cmd("write")
  vim.b[buf].autoformat = nil
end

return M
