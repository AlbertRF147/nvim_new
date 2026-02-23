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
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Word with case
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = {
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
				},
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
}
