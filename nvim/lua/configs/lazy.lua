local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    require("plugins.snacks"),
    require("plugins.ui"),
    require("plugins.lsp"),
    require("plugins.editor"),
    require("plugins.git"),
    require("plugins.debug"),
    require("plugins.ai"),

    { "MunifTanjim/nui.nvim", lazy = true },
  },
})

-- Override Lazy UI keys for JKIL navigation
local ViewConfig = require("lazy.view.config")
ViewConfig.commands.install.key_plugin = "<M-i>"
