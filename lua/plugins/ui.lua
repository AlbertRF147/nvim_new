return {
	-- Modern Buffer Removal (prevents layout collapse)
	{
		"echasnovski/mini.bufremove",
		version = false,
	},

	-- The UI "Toolkit"
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
		keys = {
			-- Professional Buffer Management
			{
				"<leader>bD",
				function()
					-- Deletes all buffers except the current one
					local current = vim.api.nvim_get_current_buf()
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
							require("mini.bufremove").delete(buf, false)
						end
					end
				end,
				desc = "Delete other buffers",
			},
			{
				"<leader>bd",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete current buffer",
			},
			-- Your Custom Split Logic (New Buffer in Split)
			{
				"<leader>bv",
				function()
					vim.cmd("vsplit")
					local win = vim.api.nvim_get_current_win()
					local buf = vim.api.nvim_create_buf(true, true)
					vim.api.nvim_win_set_buf(win, buf)
				end,
				desc = "Vertical split (New Buf)",
			},
			{
				"<leader>bs",
				function()
					vim.cmd("split")
					local win = vim.api.nvim_get_current_win()
					local buf = vim.api.nvim_create_buf(true, true)
					vim.api.nvim_win_set_buf(win, buf)
				end,
				desc = "Horizontal split (New Buf)",
			},
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "catppuccin-mocha",
				component_separators = "|",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
				lualine_c = {
					{ "filename", path = 1 },
				},
			},
		},
	},

	{
		"sphamba/smear-cursor.nvim",
		opts = {},
		config = function()
			require("smear_cursor").setup({
				stiffness = 0.8,
				trailing_stiffness = 0.5,
				distance_stop_animating = 0.5,
			})
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			-- Noice requires these to render the UI and notifications properly
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				-- Override markdown rendering so LSP docs look beautiful inside Noice
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				-- Disable the intrusive "hover" documentation change if you prefer standard LSP hover
				hover = { enabled = false },
				signature = { enabled = false },
			},
			presets = {
				bottom_search = true, -- Places the search count/search bar at the bottom instead of a giant center popup
				command_palette = true, -- Positions the command line (:) as a sleek popup in the upper center
				long_message_to_split = true, -- Sends massive messages (like stack traces) into a regular split buffer instead of a popup
				inc_rename = false, -- Set to true if you use the 'smjonas/inc-rename.nvim' plugin
			},
			routes = {
				-- SEEDING SANITY: Silence the annoying "written" notifications every time you save a file (:w)
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
				-- Silence LSP background progress notifications if they clutter your screen
				{
					filter = {
						event = "lsp",
						kind = "progress",
					},
					opts = { skip = true },
				},
			},
            views = {
                cmdline_popup = {
                    position = {
                        row = "40%",
                        col = "50%",
                    },
                    size = {
                        width = 60,
                        height = "auto",
                    },
                },
            },
		},
		config = function(_, opts)
			require("noice").setup(opts)
		end,
	},
}
