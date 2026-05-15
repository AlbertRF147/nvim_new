local red_color = "#ff0000"
local green_color = "#00e64d"
local yellow_color = "#e6e600"

local function get_theme_colors(use_stock_colors)
	-- Try to get colors from the active colorscheme
	local colors = {}

	if use_stock_colors then
		colors = {
			red = red_color,
			green = green_color,
			yellow = yellow_color,
			blue = "#89b4fa",
			sky = "#89dceb",
			text = "#cdd6f4",
			surface0 = "#313244",
		}
        return colors
	end

	-- Attempt to get catppuccin colors if available
	local ok, catppuccin = pcall(require, "catppuccin.palettes")
	if ok then
		local palette = catppuccin.get_palette() -- Gets the active variant palette
		colors = {
			red = palette.red,
			green = palette.green,
			yellow = palette.yellow,
			blue = palette.blue,
			sky = palette.sky,
			text = palette.text,
			surface0 = palette.surface0,
		}
	else
		-- Fallback: derive from existing highlight groups
		local add = vim.api.nvim_get_hl(0, { name = "GitSignsAdd" })
		local delete = vim.api.nvim_get_hl(0, { name = "GitSignsDelete" })
		local change = vim.api.nvim_get_hl(0, { name = "GitSignsChange" })

		colors = {
			red = delete.fg and string.format("#%06x", delete.fg) or "#f38ba8",
			green = add.fg and string.format("#%06x", add.fg) or "#a6e3a1",
			yellow = change.fg and string.format("#%06x", change.fg) or "#f9e2af",
			blue = "#89b4fa",
			sky = "#89dceb",
			text = "#cdd6f4",
			surface0 = "#313244",
		}
	end

	return colors
end

local function blend(fg, bg, alpha)
	local function hex_to_rgb(hex)
		hex = hex:gsub("#", "")
		return {
			r = tonumber(hex:sub(1, 2), 16),
			g = tonumber(hex:sub(3, 4), 16),
			b = tonumber(hex:sub(5, 6), 16),
		}
	end

	local function rgb_to_hex(rgb)
		return string.format("#%02x%02x%02x", rgb.r, rgb.g, rgb.b)
	end

	local fg_rgb = hex_to_rgb(fg)
	local bg_rgb = hex_to_rgb(bg)

	return rgb_to_hex({
		r = math.floor(alpha * fg_rgb.r + (1 - alpha) * bg_rgb.r),
		g = math.floor(alpha * fg_rgb.g + (1 - alpha) * bg_rgb.g),
		b = math.floor(alpha * fg_rgb.b + (1 - alpha) * bg_rgb.b),
	})
end

local function setup_highlights()
	local colors = get_theme_colors(true)
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	local normal_bg = normal.bg and string.format("#%06x", normal.bg) or "#1e1e1e"

	-- PR Tree highlights using theme colors
	vim.api.nvim_set_hl(0, "PrTreeModified", { fg = colors.yellow })
	vim.api.nvim_set_hl(0, "PrTreeAdded", { fg = colors.green })
	vim.api.nvim_set_hl(0, "PrTreeDeleted", { fg = colors.red })
	vim.api.nvim_set_hl(0, "PrTreeRenamed", { fg = colors.sky })
	vim.api.nvim_set_hl(0, "PrTreeFile", { fg = colors.text })
	vim.api.nvim_set_hl(0, "PrTreeFolder", { fg = colors.blue })

	-- GitSigns diff line backgrounds (subtle blends with theme colors)
	vim.api.nvim_set_hl(0, "GitSignsAddLn", {
		bg = blend(colors.green, normal_bg, 0.35),
	})
	vim.api.nvim_set_hl(0, "GitSignsDeleteLn", {
		bg = blend(colors.red, normal_bg, 0.35),
	})
	vim.api.nvim_set_hl(0, "GitSignsChangeLn", {
		bg = blend(colors.yellow, normal_bg, 0.35),
	})
	vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", {
		bg = blend(colors.red, normal_bg, 0.35),
	})

	-- Line number highlights
	vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = colors.green, bold = true })
	vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = colors.yellow, bold = true })
	vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = colors.red, bold = true })
end

setup_highlights()

-- Reapply highlights after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = setup_highlights,
})
