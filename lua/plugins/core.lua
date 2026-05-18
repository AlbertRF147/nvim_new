local dashboard = require("config.dashboard")

return {
	{ "nvim-lua/plenary.nvim" },

	-- Colorscheme (Modern and Professional)
	{
		"marko-cerovac/material.nvim",
		config = function()
			vim.g.material_style = "darker"
			require("material").setup({
				contrast = {
					sidebars = true,
					floating_windows = true,
					line_numbers = true,
					sign_column = true,
					-- cursor_line = true,
					non_current_windows = true,
					lsp_virtual_text = true,
				},
				custom_highlights = {
					-- Override the snacks picker active line behavior
					SnacksPickerListCursorLine = {
						bg = "#2e3c43", -- Match it to your material dark aesthetics
						fg = "#ffffff", -- Keep text legible
						bold = true,
					},
					-- Optional: If you use the snacks file explorer, it also relies on this:
					SnacksExplorerRowActive = {
						bg = "#2e3c43",
						fg = "#ffffff",
						bold = true,
					},
					-- Make the borders pop with a distinct color (e.g., Material Cyan/Blue)
					SnacksPickerBorder = { fg = "#80cbc4" }, -- Main picker border
					SnacksPickerInputBorder = { fg = "#80cbc4" }, -- Input/search bar border
				},
			})
			vim.cmd("colorscheme material")
		end,
	},
	-- {
	-- 	"catppuccin/nvim",
	-- 	name = "catppuccin",
	-- 	priority = 1000,
	-- 	opts = {
	-- 		blink_cmp = {
	-- 			style = "bordered",
	-- 		},
	-- 		integrations = {
	-- 			gitsigns = true,
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		vim.cmd.colorscheme("catppuccin-mocha")
	-- 	end,
	-- },

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
			lazygit = {
				enabled = true,
			},
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

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function(bufnr)
				local gs = require("gitsigns")

				local base = vim.g.pr_review_active and vim.g.pr_review_base or nil
				if base and base ~= "" then
					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(bufnr) then
							return
						end

						gs.change_base(base, bufnr)
						gs.refresh()
					end)
				end
			end,
		},
	},

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
