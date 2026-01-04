local opt = vim.opt
local o = vim.o

opt.guicursor = ""

o.mouse = "a"

o.clipboard = "unnamedplus"

o.breakindent = true

-- Decrease update time
o.updatetime = 250
o.timeoutlen = 300

o.completeopt = "menuone,noselect"

opt.timeoutlen = 500
vim.g.which_key_timeout = 500

opt.nu = true
-- opt.relativenumber = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.autoread = true
-- opt.buftype = "nofile"

-- opt.smartindent = true

opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.hlsearch = true
opt.incsearch = true

opt.termguicolors = true

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

opt.updatetime = 50

opt.colorcolumn = "80"

opt.cursorline = true

vim.filetype.add({
  extension = {
    ejs = 'embedded_template'
  }
})

-- Disable providers we don't use
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- vim.lsp.set_log_level("OFF")

-- Supress deprecation warning from lspconfig
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if msg:match("require%('lspconfig'%)") then
    return
  end
  notify(msg, level, opts)
end

-- If a colorscheme forces its own guicursor, re-apply this afterwards.

