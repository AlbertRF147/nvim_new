return {
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
				highlight_ns = vim.api.nvim_create_namespace("blink_appearance"),
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			completion = {
				documentation = {
					-- Controls whether the documentation window opens automatically
					auto_show = true,
					-- How long to wait before showing the window (set to 0 for instant)
					auto_show_delay_ms = 200,
					-- Style the window (optional)
					window = {
						border = "rounded",
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
						max_width = 80,
						max_height = 40,
					},
				},
				menu = {
					draw = {
						components = {
							-- customize the drawing of kind icons
							kind_icon = {
								text = function(ctx)
									-- default kind icon
									local icon = ctx.kind_icon
									-- if LSP source, check for color derived from documentation
									if ctx.item.source_name == "LSP" then
										local color_item = require("nvim-highlight-colors").format(
											ctx.item.documentation,
											{ kind = ctx.kind }
										)
										if color_item and color_item.abbr ~= "" then
											icon = color_item.abbr
										end
									end
									return icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									-- default highlight group
									local highlight = "BlinkCmpKind" .. ctx.kind
									-- if LSP source, check for color derived from documentation
									if ctx.item.source_name == "LSP" then
										local color_item = require("nvim-highlight-colors").format(
											ctx.item.documentation,
											{ kind = ctx.kind }
										)
										if color_item and color_item.abbr_hl_group then
											highlight = color_item.abbr_hl_group
										end
									end
									return highlight
								end,
							},
						},
					},
				},
			},
			-- If you also want to see function signatures (parameters) as you type:
			signature = {
				enabled = true,
				window = { border = "rounded" },
			},
		},
	},
}
