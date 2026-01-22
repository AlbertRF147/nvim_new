return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		requires = { { "nvim-lua/plenary.nvim" } },
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon Add",
			},
			{
				"<leader>h",
				function()
					local h = require("harpoon")
					h.ui:toggle_quick_menu(h:list())
				end,
				desc = "Harpoon Menu",
			},
			{
				"<Left>",
				function()
					require("harpoon"):list():prev()
				end,
				desc = "Harpoon Prev",
			},
			{
				"<Right>",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Harpoon Next",
			},
		},
	},
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		lazy = false,
		keys = {
			{ "<leader>fv", "<cmd>Oil<cr>", desc = "Oil File Manager" },
		},
	},
	{
		"echasnovski/mini.files",
		keys = {
			{
				"<leader>ft",
				function()
					require("mini.files").open()
				end,
				desc = "Mini Files",
			},
			{
				"<leader>fT",
				function()
					require("mini.files").open(vim.api.nvim_buf_get_name(0))
				end,
				desc = "Mini Files (Current Dir)",
			},
		},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			picker = { enabled = true, matcher = { ignorecase = false } },
		},
		keys = {
			-- Top-tier Pickers (Replacing Telescope)
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fs",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep (Live Search)",
			},
			{
				"<leader>fh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Tags",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent Files",
			},
		},
	},

	{
		"karb94/neoscroll.nvim",
		config = function()
			local ns = require("neoscroll")
			ns.setup({
				duration_multiplier = 1.0,
				post_hook = function(info)
					vim.cmd("normal! zz")
				end,
			})
			local keymap = {
				["<C-u>"] = function()
					ns.ctrl_u({ duration = 80, info = { "center_me" } })
				end,
				["<C-d>"] = function()
					ns.ctrl_d({ duration = 80, info = { "center_me" } })
				end,
			}
			local modes = { "n", "v", "x" }
			for key, func in pairs(keymap) do
				vim.keymap.set(modes, key, func)
			end
		end,
	},
}
