local api = vim.api

api.nvim_create_autocmd(
	"FileType",
	{ pattern = { "help", "startuptime", "qf", "lspinfo", "codecompanion" }, command = [[nnoremap <buffer><silent> q :close<CR>]] }
)

api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("help_window_right", {}),
	-- pattern = { "*.txt" },
	callback = function()
		if vim.o.filetype == "help" then
			vim.cmd.wincmd("L")
		end
	end,
})

api.nvim_create_autocmd("FileType", {
	pattern = { "qf" },
	command = [[
    nnoremap <buffer><silent> dd :.Reject<CR>
    xnoremap <buffer><silent> d :'<,'>Reject<CR>
  ]],
})

-- Disable hover in favor of Pyright
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end
	end,
	desc = "LSP: Disable hover capability from Ruff",
})
