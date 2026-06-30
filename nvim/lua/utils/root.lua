---@class utils.root
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

---@alias RootSpec string|string[]|fun(buf: number): (string|string[])

--- Priority: LSP workspace -> pattern (".git", ".luarc.json") → cwd
---@type RootSpec[]
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

M.detectors = {}

function M.detectors.cwd()
  return { vim.uv.cwd() }
end

function M.detectors.lsp(buf)
  local bufpath = vim.api.nvim_buf_get_name(buf)
  if bufpath == "" then
    return {}
  end
  local roots = {}
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in pairs(clients) do
    for _, ws in pairs(client.config.workspace_folders or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end
  return vim.tbl_filter(function(path)
    return path and vim.startswith(bufpath, vim.fs.normalize(path))
  end, roots)
end

function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" then
    path = vim.uv.cwd()
  end
  local found = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]
  return found and { vim.fs.dirname(found) } or {}
end

---@type table<number, string>
M.cache = {}

function M.setup()
  vim.api.nvim_create_user_command("Root", function()
    local root = M.get()
    vim.notify("Project root: " .. root, vim.log.levels.INFO, { title = "Root" })
  end, { desc = "Show project root for current buffer" })

  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("util_root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
end

---@param opts? { buf?: number }
---@return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]
  if not ret then
    for _, spec in ipairs(M.spec) do
      local detector = M.detectors[spec] or function(b)
        return M.detectors.pattern(b, spec)
      end
      local paths = detector(buf)
      paths = type(paths) == "table" and paths or { paths }
      for _, p in ipairs(paths) do
        if p and vim.uv.fs_stat(p) then
          ret = vim.fs.normalize(p)
          break
        end
      end
      if ret then
        break
      end
    end
    ret = ret or vim.uv.cwd()
    M.cache[buf] = ret
  end
  return ret
end

---@return string
function M.git()
  return vim.fs.root(0, ".git") or M.get()
end

return M
