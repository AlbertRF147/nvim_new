local dashboard = require("config.dashboard")

return {
	{ "nvim-lua/plenary.nvim" },

	-- Colorscheme (Modern and Professional)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			blink_cmp = {
				style = "bordered",
			},
		},
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

	{ "lewis6991/gitsigns.nvim" },

	{
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup({
				view = {
					default = {
						layout = "diff2_vertical",
					},
				},
			})
		end,
		keys = {
			{
				"<leader>dc",
				function()
					vim.cmd("DiffviewClose")
				end,
				{ desc = { "Close Diffview " } },
			},
			{
				"<leader>dh",
				function()
					Snacks.picker.git_log({
						layout = {
							hidden = { "preview" },
							layout = {
								backdrop = false,
								width = 0.9,
								min_width = 150,
								max_width = 200,
								height = 0.4,
								min_height = 2,
								box = "vertical",
								border = true,
								title = "{title}",
								title_pos = "center",
								{ win = "input", height = 1, border = "bottom" },
								{ win = "list", border = "none" },
								{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
							},
						},
						confirm = function(picker, item)
							picker:close()
							vim.cmd("DiffviewOpen " .. item.commit .. "^!")
						end,
					})
				end,
				desc = "Git Log (DiffView)",
			},
		},
	},
}
