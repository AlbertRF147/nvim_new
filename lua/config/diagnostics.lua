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

local last_hover_win = nil
local ns = vim.api.nvim_create_namespace("smart_k_hover")

vim.keymap.set("n", "K", function()
  -- If popup already exists, jump into it
  if last_hover_win and vim.api.nvim_win_is_valid(last_hover_win) then
    vim.api.nvim_set_current_win(last_hover_win)
    return
  end

  local bufnr = 0
  local line = vim.fn.line(".") - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  local diag_lines = {}
  local diag_hls = {} -- map: line_index_in_popup -> hl_group (we'll fill after we know offsets)

  for _, d in ipairs(diagnostics) do
    local prefix =
      d.severity == vim.diagnostic.severity.ERROR and " " or
      d.severity == vim.diagnostic.severity.WARN  and " " or
      d.severity == vim.diagnostic.severity.INFO  and " " or
      d.severity == vim.diagnostic.severity.HINT  and " " or ""

    local hl =
      d.severity == vim.diagnostic.severity.ERROR and "DiagnosticError" or
      d.severity == vim.diagnostic.severity.WARN  and "DiagnosticWarn"  or
      d.severity == vim.diagnostic.severity.INFO  and "DiagnosticInfo"  or
      d.severity == vim.diagnostic.severity.HINT  and "DiagnosticHint"  or
      "Normal"

    table.insert(diag_lines, prefix .. d.message)
    table.insert(diag_hls, hl) -- one per diagnostic line
  end

  vim.lsp.buf_request_all(bufnr, "textDocument/hover", vim.lsp.util.make_position_params(), function(results)
    local hover_lines = {}
    for _, res in pairs(results) do
      if res.result and res.result.contents then
        local contents = vim.lsp.util.convert_input_to_markdown_lines(res.result.contents)
        contents = vim.lsp.util.trim_empty_lines(contents)
        vim.list_extend(hover_lines, contents)
      end
    end

    local lines = {}
    local diag_start = nil -- line index where diagnostic messages begin inside `lines`

    if #diag_lines > 0 then
      vim.list_extend(lines, { "Diagnostics:", "─────────────" })
      diag_start = #lines + 1
      vim.list_extend(lines, diag_lines)
      if #hover_lines > 0 then table.insert(lines, "") end
    end

    if #hover_lines > 0 then
      vim.list_extend(lines, { "Documentation:", "───────────────" })
      vim.list_extend(lines, hover_lines)
    end

    if #lines == 0 then
      lines = { "No diagnostics or documentation available." }
    end

    local float_buf, winid = vim.lsp.util.open_floating_preview(lines, "markdown", {
      border = "rounded",
      focusable = true,
      close_events = { "BufHidden", "InsertEnter", "CursorMoved" },
    })

    last_hover_win = winid

    -- Clear old highlights (important if you reuse buffers)
    vim.api.nvim_buf_clear_namespace(float_buf, ns, 0, -1)

    -- Apply severity highlights to diagnostic lines
    if diag_start then
      for i, hl in ipairs(diag_hls) do
        local lnum = (diag_start - 1) + (i - 1) -- 0-based
        -- highlight the whole line
        vim.api.nvim_buf_add_highlight(float_buf, ns, hl, lnum, 0, -1)
      end
    end

    -- Reset stored winid when it closes
    vim.api.nvim_create_autocmd("WinClosed", {
      once = true,
      callback = function()
        last_hover_win = nil
      end,
    })
  end)
end, { desc = "Smart K: diagnostics/docs, press again to focus" })

