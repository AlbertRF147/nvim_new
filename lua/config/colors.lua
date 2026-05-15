local red_color = "#ff0000"
local green_color = "#00e64d"
local yellow_color = "#e6e600"

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
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	local normal_bg = normal.bg and string.format("#%06x", normal.bg) or "#1e1e1e"

	-- PR Tree highlights
	vim.api.nvim_set_hl(0, "PrTreeModified", { fg = yellow_color })
	vim.api.nvim_set_hl(0, "PrTreeAdded", { fg = green_color })
	vim.api.nvim_set_hl(0, "PrTreeDeleted", { fg = red_color })
	vim.api.nvim_set_hl(0, "PrTreeRenamed", { fg = "#56b6c2" })
	vim.api.nvim_set_hl(0, "PrTreeFile", { fg = "#abb2bf" })
	vim.api.nvim_set_hl(0, "PrTreeFolder", { fg = "#61afef" })

	-- GitSigns diff line backgrounds (brighter for visibility)
	vim.api.nvim_set_hl(0, "GitSignsAddLn", {
		bg = blend(green_color, normal_bg, 0.35),
	})
    vim.api.nvim_set_hl(0, "GitSignsDeleteLn", {
        bg = blend(red_color, normal_bg, 0.35),
    })
    vim.api.nvim_set_hl(0, "GitSignsChangeLn", {
        bg = blend(yellow_color, normal_bg, 0.35),
    })

	vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#3d5a3d" })
	vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", { bg = "#6b3a42" })
	vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = green_color, bold = true })
	vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = yellow_color, bold = true })
	vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = red_color, bold = true })
end

setup_highlights()

-- Reapply highlights after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = setup_highlights,
})
