local dashboard = require("config.dashboard")

return {
	{ "nvim-lua/plenary.nvim" },

	-- The New King of Completion: Blink.cmp
	{
		"saghen/blink.cmp",
		version = "*", -- use a release tag to download pre-built binaries
		opts = {
			keymap = {
				preset = "default",
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Right>"] = { "select_and_accept", "fallback" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
	},

	-- Colorscheme (Modern and Professional)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>f", group = "file/find" },
				{ "<leader>b", group = "buffer" },
				{ "<leader>g", group = "git" },
				{ "<leader>d", group = "diff/debug" },
				{ "<leader>w", group = "windows", proxy = "<C-w>" }, -- Proxies leader-w to ctrl-w
			},
		},
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			dashboard = dashboard,
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			scope = { enabled = true },
			lazygit = { enabled = true },
		},
		keys = {
			{
				"<leader>g",
				function()
					Snacks.lazygit.open()
				end,
				desc = "Find Files",
			},
		},
	},

	{ "tpope/vim-surround" },
}
