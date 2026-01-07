return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			{
				"williamboman/mason-lspconfig.nvim",
				opts = {
					ensure_installed = { "lua_ls", "ts_ls", "pyright", "ruff" },
				},
			},
			"saghen/blink.cmp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Neovim 0.11 Native Enable
			-- mason-lspconfig v2+ automatically calls vim.lsp.enable()
			-- for servers installed via Mason.

			-- Customizing specific servers (The Modern Way)
			-- You no longer use .setup({}). You use vim.lsp.config()
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						completion = { callSnippet = "Replace" },
					},
				},
			})

			-- Global LSP keybinds via LspAttach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local opts = { buffer = args.buf }

					-- Navigation
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition", buffer = args.buf })
					vim.keymap.set("n", "grr", vim.lsp.buf.references, { desc = "Goto References", buffer = args.buf })
					vim.keymap.set(
						"n",
						"gi",
						vim.lsp.buf.implementation,
						{ desc = "Goto Implementation", buffer = args.buf }
					)
					vim.keymap.set(
						"n",
						"gy",
						vim.lsp.buf.type_definition,
						{ desc = "Goto Type Definition", buffer = args.buf }
					)

					-- Actions
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs", buffer = args.buf })
					vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename", buffer = args.buf })
					vim.keymap.set(
						{ "n", "v" },
						"<leader>ca",
						vim.lsp.buf.code_action,
						{ desc = "Code Action", buffer = args.buf }
					)

					-- Inlay Hints (A professional must-have)
					if client and client.supports_method("textDocument/inlayHint") then
						local toggle_inline_hint = function()
							local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
							local to_value = not enabled
							vim.lsp.inlay_hint.enable(to_value, { bufnr = args.buf })
							if to_value then
								vim.notify("Inline Hints Enabled")
							else
								vim.notify("Inline Hints Disabled")
							end
						end
						vim.keymap.set("n", "<leader>ti", toggle_inline_hint, { desc = "Toggle Inline Hints" })
					end
				end,
			})
		end,
	},

	-- Professional Auto-formatting
	{
		"stevearc/conform.nvim",
		-- No need for "event = 'BufWritePre'" if we aren't formatting on save!
		-- This makes your startup even faster.
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>bf", -- "Buffer Format"
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				mode = { "n", "v" }, -- Works in Normal and Visual mode
				desc = "Format buffer (or selection)",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				-- Use "-" to disable formatting for specific filetypes
				-- markdown = { "-" },
			},
			-- format_on_save = nil, -- Explicitly disabled
		},
	},

	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{ -- optional blink completion source for require statements and module annotations
		"saghen/blink.cmp",
		opts = {
			sources = {
				-- add lazydev to your completion providers
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
		},
	},
}
