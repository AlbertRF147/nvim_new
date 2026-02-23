return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "BufReadPost",
		opts = {
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<Tab>", -- handled by nvim-cmp / blink.cmp
					next = "<M-]>",
					prev = "<M-[>",
				},
			},
			should_attach = function(_, bufname)
				local weekday = tonumber(os.date("%w"))
				local hour = tonumber(os.date("%H"))
				if weekday >= 1 and weekday <= 5 then
					if hour >= 8 and hour <= 17 and bufname:match("/controlamaterial/") then
						return false
					end
				end
				return true
			end,
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},

	{
		"olimorris/codecompanion.nvim",
		version = "^18.0.0",
		opts = {},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion", "blink_cmp_menu", "blink_cmp_docs" },
	},
}
