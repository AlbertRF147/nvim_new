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
		source = true,
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
vim.keymap.set("n", "<leader>tD", toggle_virtual_text, { desc = "Toggle Inline Diagnostics" })

vim.keymap.set("n", "K", function()
	local line = vim.fn.line(".") - 1
	local diagnostics = vim.diagnostic.get(0, { lnum = line })
	local has_diagnostics = #diagnostics > 0

	-- Function to show diagnostics
	local show_diag = function()
		vim.diagnostic.open_float({ scope = "line", border = "rounded"})
		vim.diagnostic.open_float() -- autofocus
	end

	-- Function to show LSP hover
	local show_lsp = function()
		vim.lsp.buf.hover({ border = "rounded", focus = true })
		vim.lsp.buf.hover() -- autofocus
	end

	-- Logic Gate
	if has_diagnostics then
		-- We have errors. Now check if LSP has info (most symbols do)
		-- We trigger a choice menu
		vim.ui.select({
			"󱖫 Show Diagnostic Error",
			"󰋼 Show Documentation / Type",
		}, {
			prompt = "Multiple info types available:",
		}, function(choice)
			if choice == "󱖫 Show Diagnostic Error" then
				show_diag()
			elseif choice == "󰋼 Show Documentation / Type" then
				show_lsp()
			end
		end)
	else
		-- No errors? Just show the standard docs immediately
		show_lsp()
	end
end, { desc = "Smart K: Choose between Error or Docs" })
