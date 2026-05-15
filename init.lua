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

-- 3. Auto-load all config files
local config_path = vim.fn.stdpath("config") .. "/lua/config"
local config_files = vim.fn.readdir(config_path)

for _, file in ipairs(config_files) do
  if file:match("%.lua$") then
    require("config." .. file:gsub("%.lua$", ""))
  end
end
