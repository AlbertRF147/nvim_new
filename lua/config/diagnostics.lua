-- Add to lua/config/options.lua or a dedicated diagnostics file
local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = { prefix = "●" }, -- Smaller, less intrusive
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

local function toggle_virtual_text()
  local current_state = vim.diagnostic.config().virtual_text
  if current_state then
    vim.diagnostic.config({ virtual_text = false })
    vim.notify("Virtual Text Disabled", vim.log.levels.INFO)
  else
    vim.diagnostic.config({ virtual_text = true })
    vim.notify("Virtual Text Enabled", vim.log.levels.INFO)
  end
end

-- Bind it to <leader>dt (Diagnostic Toggle)
vim.keymap.set("n", "<leader>td", toggle_virtual_text, { desc = "Toggle Inline Diagnostics" })
