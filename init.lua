-- Set leader key before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 1. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({{ "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }}, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 2. Load plugins from lua/plugins/*.lua
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
})

-- 3. Load basic settings (create these files next)
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.diagnostics")
