return {
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
