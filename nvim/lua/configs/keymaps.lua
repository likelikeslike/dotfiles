-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  opts.desc = desc
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Mode shortcuts
local n = "n"
local v = "v"
local i = "i"
local nv = { n, v }
local nvi = { n, v, i }

-- ══════════════════════════════════════════════════════════════════════════════
-- Core Navigation (JKIL Layout)
-- ══════════════════════════════════════════════════════════════════════════════
-- j = left (h)
-- k = down (j)
-- i = up (k)
-- l = right (l)
-- h = insert (i)

map(nv, "<Space>", "<Nop>", " 󱁐 ", { silent = true })

-- Insert mode mappings
map(nv, "h", "i", "Insert")
map(nv, "H", "I", "Insert at beginning of line")

-- Movement mappings (JKIL)
map(nv, "i", "v:count == 0 ? 'gk' : 'k'", "Up", { expr = true, silent = true })
-- JKIL: overrides default visual-mode lowercase; use gu instead
map(v, "u", "v:count == 0 ? 'gk' : 'k'", "Up", { expr = true, silent = true })
map(nv, "k", "v:count == 0 ? 'gj' : 'j'", "Down", { expr = true, silent = true })
map(nv, "I", "5k", "Up (fast)")
map(nv, "K", "5j", "Down (fast)")
map(nv, "j", "h", "Left")
map(nv, "l", "l", "Right")

-- ══════════════════════════════════════════════════════════════════════════════
-- File Operations
-- ══════════════════════════════════════════════════════════════════════════════
map(nvi, "<C-s>", "<cmd>w<cr><esc>", "Save file")
map(n, "<leader>fs", "<cmd>w<cr>", "Save with formatting")
map(n, "<leader>fS", function()
  require("utils.format").save_no_format()
end, "Save without formatting")
map(nvi, "<C-q>", "<cmd>q<cr>", "Quit")
map(nv, "q", "<cmd>q<cr>", "Quit")
map(nvi, "<C-q><C-q>", "<cmd>q!<cr>", "Force quit")
map(n, "<leader>q", "q", "Start/stop macro recording")
map(n, "<leader>ce", "<cmd>e<cr>", "Reload buffer")

-- ══════════════════════════════════════════════════════════════════════════════
-- Search and Highlights
-- ══════════════════════════════════════════════════════════════════════════════
map(n, "<esc>", "<cmd>noh<cr>", "Clear highlights")
map(n, "<leader>mv", function()
  local lnum = vim.fn.line(".")
  local buf = vim.api.nvim_get_current_buf()
  local found = {}
  for _, m in ipairs(vim.fn.getmarklist(buf)) do
    if m.pos[2] == lnum then
      local name = m.mark:sub(2)
      local col = m.pos[3] + 1
      found[#found + 1] = string.format("  '%s  col %d", name, col)
    end
  end
  if #found > 0 then
    vim.notify("Marks on line " .. lnum .. ":\n" .. table.concat(found, "\n"), vim.log.levels.INFO)
  else
    vim.notify("No marks on this line", vim.log.levels.INFO)
  end
end, "View marks on current line")

map(n, "<leader>md", function()
  local lnum = vim.fn.line(".")
  local to_delete = {}
  for _, m in ipairs(vim.fn.getmarklist(vim.api.nvim_get_current_buf())) do
    local name = m.mark:sub(2)
    if m.pos[2] == lnum and name:match("^[a-z]$") then
      to_delete[#to_delete + 1] = name
    end
  end
  if #to_delete > 0 then
    vim.cmd("delmarks " .. table.concat(to_delete, " "))
    vim.notify("Deleted marks: " .. table.concat(to_delete, " "), vim.log.levels.INFO)
  else
    vim.notify("No local marks on this line", vim.log.levels.INFO)
  end
end, "Delete marks on current line")
map(n, "n", "nzzzv", "Find next and center")
map(n, "N", "Nzzzv", "Find previous and center")

-- ══════════════════════════════════════════════════════════════════════════════
-- Text Editing
-- ══════════════════════════════════════════════════════════════════════════════
map(n, "<C-.>", "<C-a>", "Increment number")
map(n, "<C-,>", "<C-x>", "Decrement number")
map(n, "x", '"_x', "Delete without yanking")
map(v, "p", '"_dP', "Paste without overwriting register")
map(v, "<", "<gv", "Indent left")
map(v, ">", ">gv", "Indent right")

-- Line movement (Alt + JKIL for consistency)
map(n, "<A-k>", "<cmd>m .+1<cr>", "Move line down")
map(n, "<A-i>", "<cmd>m .-2<cr>", "Move line up")
map(v, "<A-k>", ":m '>+1<cr>gv", "Move selection down")
map(v, "<A-i>", ":m '<-2<cr>gv", "Move selection up")

-- ══════════════════════════════════════════════════════════════════════════════
-- Buffer Management
-- ══════════════════════════════════════════════════════════════════════════════
map(n, "<leader>bn", "<cmd>enew<cr>", "New buffer")
map(n, "`p", "<C-o>", "Jump to previous cursor location (cross buffer)")
map(n, "`n", "<C-i>", "Jump to next cursor location (cross buffer)")

-- ══════════════════════════════════════════════════════════════════════════════
-- Window Management
-- ══════════════════════════════════════════════════════════════════════════════
-- Window creation
map(n, "<leader>v", "<C-w>v", "Vertical split")
map(n, "<leader>h", "<C-w>s", "Horizontal split")
map(n, "<leader>=", "<C-w>=", "Equalize splits")
map(n, "<leader>xs", "<cmd>close<cr>", "Close split")

-- Window navigation (Ctrl + JKIL)
map(n, "<C-j>", "<cmd>wincmd h<cr>", "Move to left window")
map(n, "<C-l>", "<cmd>wincmd l<cr>", "Move to right window")
-- <C-i> is terminal-equivalent to <Tab>, so this also overrides jump-forward
map(n, "<C-i>", "<cmd>wincmd k<cr>", "Move to top window")
map(n, "<C-k>", "<cmd>wincmd j<cr>", "Move to bottom window")

-- Alternative window navigation (Leader + w + JKIL)
map(n, "<leader>wj", "<cmd>wincmd h<cr>", "Move to left window")
map(n, "<leader>wl", "<cmd>wincmd l<cr>", "Move to right window")
map(n, "<leader>wi", "<cmd>wincmd k<cr>", "Move to top window")
map(n, "<leader>wk", "<cmd>wincmd j<cr>", "Move to bottom window")

-- Window movement (Leader + w + uppercase JKIL)
map(n, "<leader>wJ", "<cmd>wincmd H<cr>", "Move window to far left")
map(n, "<leader>wL", "<cmd>wincmd L<cr>", "Move window to far right")
map(n, "<leader>wI", "<cmd>wincmd K<cr>", "Move window to far top")
map(n, "<leader>wK", "<cmd>wincmd J<cr>", "Move window to far bottom")

-- Window resizing (Leader + arrow keys)
map(n, "<leader><Up>", "<cmd>resize +2<cr>", "Increase height")
map(n, "<leader><Down>", "<cmd>resize -2<cr>", "Decrease height")
map(n, "<leader><Left>", "<cmd>vertical resize -2<cr>", "Decrease width")
map(n, "<leader><Right>", "<cmd>vertical resize +2<cr>", "Increase width")

-- ══════════════════════════════════════════════════════════════════════════════
-- Diagnostics
-- ══════════════════════════════════════════════════════════════════════════════
map(n, "<leader>dd", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  if #diagnostics == 0 then
    vim.notify("No diagnostics on current line", vim.log.levels.WARN)
    return
  end
  local messages = {}
  for _, d in ipairs(diagnostics) do
    table.insert(messages, d.message)
  end
  local text = table.concat(messages, "\n")
  vim.fn.setreg("+", text)
  vim.notify("Copied diagnostic: " .. text, vim.log.levels.INFO)
end, "Copy diagnostic message")

-- ══════════════════════════════════════════════════════════════════════════════
-- Toggles
-- ══════════════════════════════════════════════════════════════════════════════
map(n, "<leader>uf", function()
  require("utils.format").toggle()
end, "Toggle autoformat (global)")

map(n, "<leader>uF", function()
  require("utils.format").toggle(true)
end, "Toggle autoformat (buffer)")

map(n, "<leader>uz", function()
  require("utils.treesitter").toggle_folds()
end, "Toggle treesitter folds")

-- ══════════════════════════════════════════════════════════════════════════════
-- Python Environment Management
-- ══════════════════════════════════════════════════════════════════════════════
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    map(n, "<leader>cv", function()
      require("utils.python-picker").configure_lsp_only()
    end, "Select Python Environment (LSP)", { buffer = ev.buf })
    map(n, "<leader>cV", function()
      require("utils.python-picker").configure_dap_python()
    end, "Select Python (Debug + LSP)", { buffer = ev.buf })
    map(n, "<leader>ci", function()
      require("utils.python-picker").show_current_env()
    end, "Show Python Environment", { buffer = ev.buf })
  end,
})
