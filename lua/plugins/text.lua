local treesitter_parsers = {
	"javascript",
	"typescript",
	"c",
	"lua",
	"rust",
	"python",
	"embedded_template",
	"c_sharp",
	"markdown",
	"markdown_inline",
	"sql",
	"toml",
	"yaml",
	"json",
	"css",
	"html",
}

return {
	{
		"nvim-mini/mini.pairs",
		version = "*",
		config = function()
			require("mini.pairs").setup({})
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = true, -- Auto close on trailing </
					-- update_on_insert = true, -- Update tags in insert mode
				},
				per_filetype = {
					-- ["html"] = {
					-- 	enable_close = false,
					-- },
				},
				aliases = {
					["javascriptreact"] = "html",
					["typescriptreact"] = "html",
				},
			})
		end,
		event = { "BufReadPre", "BufNewFile" },
	},

	{ "tpope/vim-surround" },

	{
		"nvim-mini/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					g = function() -- 'g' for entire buffer/global
						local from = { line = 1, col = 1 }
						local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
						return { from = from, to = to }
					end,
					-- o: Target code blocks, loops, or conditionals
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					-- f: Target entire functions
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
					-- c: Target entire classes
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
					-- t: HTML/XML tags
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
					-- d: Digits / Numbers
					d = { "%f[%d]%d+" },
					-- e: Sub-words (perfect for camelCase or snake_case editing)
					e = {
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					-- u/U: Smart function calls (e.g., ciu to change arguments)
					u = ai.gen_spec.function_call(),
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
				},
			}
		end,
		config = function(_, opts)
			-- Safely catch any initialization edge-cases
			local status_ok, mini_ai = pcall(require, "mini.ai")
			if status_ok then
				mini_ai.setup(opts)
			end
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = function()
			require("nvim-treesitter").install(treesitter_parsers)
		end,
		config = function()
			require("nvim-treesitter").install(treesitter_parsers)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = treesitter_parsers,
				callback = function()
					vim.treesitter.start()
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo.foldmethod = "expr"
					vim.wo.foldenable = false
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- {
	-- 	"nvim-treesitter/nvim-treesitter-textobjects",
	-- 	dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- },

	{
		"MagicDuck/grug-far.nvim",
		config = function()
			require("grug-far").setup({})
		end,
		lazy = false,
		keys = {
			{
				"<leader>S",
				function()
					require("grug-far").open()
				end,
				desc = "Search and Replace",
			},
		},
	},

	{
		"brenoprata10/nvim-highlight-colors",
		lazy = false,
		config = function()
			local hc = require("nvim-highlight-colors")
			hc.setup({
				enable_tailwind = true,
				render = "virtual",
			})
		end,
	},

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
		config = function(_, opts)
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_format" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					typescript = { "prettierd", "prettier", stop_after_first = true },
					typescriptreact = { "prettierd", "prettier", stop_after_first = true },
					yaml = { "yamlfix" },
					json = { "prettierd", "prettier", stop_after_first = true },
					css = { "prettierd", "prettier", stop_after_first = true },
					sql = { "pg_format" },
					-- Use "-" to disable formatting for specific filetypes
					-- markdown = { "-" },
				},
				formatters = {
					yamlfix = {
						env = {
							YAMLFIX_LINE_LENGTH = "65",
							YAMLFIX_COMMENTS_REQUIRE_STARTING_SPACE = "true",
						},
					},
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				multiwindow = false, -- Enable multiwindow support.
				max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 20, -- Maximum number of lines to show for a single context
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = "=",
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			})
			vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#000000" }) -- Distinct dark slate bg
			-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#ff007c" }) -- Hot pink separator line
		end,
	},
}
