local M = {}

vim.api.nvim_set_hl(0, "PrTreeModified", { fg = "#e5c07b" })
vim.api.nvim_set_hl(0, "PrTreeAdded", { fg = "#98c379" })
vim.api.nvim_set_hl(0, "PrTreeDeleted", { fg = "#e06c75" })
vim.api.nvim_set_hl(0, "PrTreeRenamed", { fg = "#56b6c2" })
vim.api.nvim_set_hl(0, "PrTreeFile", { fg = "#abb2bf" })
vim.api.nvim_set_hl(0, "PrTreeFolder", { fg = "#61afef" })

local state = {
	base = nil,
	root = nil,
	files = {},
	tree_buf = nil,
	tree_win = nil,
}

local function systemlist(cmd, cwd)
	local result = vim.system(cmd, { cwd = cwd, text = true }):wait()

	if result.code ~= 0 then
		local err = result.stderr ~= "" and result.stderr or result.stdout
		vim.notify(err, vim.log.levels.ERROR)
		return nil
	end

	local lines = vim.split(result.stdout or "", "\n", { trimempty = true })
	return lines
end

local function git_root()
	local out = systemlist({ "git", "rev-parse", "--show-toplevel" })
	return out and out[1] or nil
end

local function default_base_candidates()
	local candidates = {}

	local head = systemlist({ "git", "symbolic-ref", "--quiet", "refs/remotes/origin/HEAD" })
	if head and head[1] then
		local ref = head[1]:gsub("^refs/remotes/", "")
		table.insert(candidates, ref)
	end

	vim.list_extend(candidates, {
		"origin/main",
		"origin/master",
		"main",
		"master",
	})

	local seen, deduped = {}, {}
	for _, item in ipairs(candidates) do
		if item ~= "" and not seen[item] then
			seen[item] = true
			table.insert(deduped, item)
		end
	end

	return deduped
end

local function changed_files(base, root)
	local out = systemlist({
		"git",
		"diff",
		"--name-status",
		base .. "...HEAD",
	}, root)

	if not out then
		return {}
	end

	local files = {}

	for _, line in ipairs(out) do
		-- Format: M file | A file | D file | R100 old new
		local parts = vim.split(line, "\t")

		local status = parts[1]
		local path = parts[#parts] -- handles rename case

		table.insert(files, {
			path = path,
			status = status,
		})
	end

	return files
end

local function build_tree(paths)
	local tree = {}
	for _, item in ipairs(paths) do
		local path = item.path
		local status = item.status

		local parts = vim.split(path, "/", { plain = true })
		local node = tree

		for i, part in ipairs(parts) do
			node.children = node.children or {}
			node.children[part] = node.children[part]
				or {
					name = part,
					path = table.concat(vim.list_slice(parts, 1, i), "/"),
					is_file = i == #parts,
					children = {},
				}

			if i == #parts then
				node.children[part].is_file = true
				node.children[part].status = status
			end

			node = node.children[part]
		end
	end
	return tree
end

local function get_status_icon(status)
	if not status then
		return ""
	end
	if status:match("^M") then
		return "● "
	end
	if status:match("^A") then
		return "✚ "
	end
	if status:match("^D") then
		return "✖ "
	end
	if status:match("^R") then
		return "➜ "
	end
	return ""
end

local function get_status_hl(status)
	if not status then
		return "PrTreeFile"
	end
	if status:match("^M") then
		return "PrTreeModified"
	end
	if status:match("^A") then
		return "PrTreeAdded"
	end
	if status:match("^D") then
		return "PrTreeDeleted"
	end
	if status:match("^R") then
		return "PrTreeRenamed"
	end
	return "PrTreeFile"
end

local function flatten_tree(tree, depth, lines, highlights, line_map)
	depth = depth or 0
	lines = lines or {}
	highlights = highlights or {}
	line_map = line_map or {}

	local names = {}
	for name, _ in pairs(tree.children or {}) do
		table.insert(names, name)
	end

	table.sort(names, function(a, b)
		local na = tree.children[a]
		local nb = tree.children[b]
		if na.is_file ~= nb.is_file then
			return not na.is_file
		end
		return a < b
	end)

	for _, name in ipairs(names) do
		local node = tree.children[name]
		local prefix = string.rep("  ", depth)

		local icon = node.is_file and "󰈔 " or "󰉋 "
		local status_icon = node.is_file and get_status_icon(node.status) or ""

		local text = prefix .. icon .. status_icon .. node.name
		table.insert(lines, text)
		line_map[#lines] = node

		-- highlight whole line
		table.insert(highlights, {
			line = #lines - 1,
			hl = node.is_file and get_status_hl(node.status) or "PrTreeFolder",
		})

		if not node.is_file then
			flatten_tree(node, depth + 1, lines, highlights, line_map)
		end
	end

	return lines, highlights, line_map
end

local function ensure_tree_window()
	if state.tree_win and vim.api.nvim_win_is_valid(state.tree_win) then
		return state.tree_win, state.tree_buf
	end

	vim.cmd("topleft vnew")
	state.tree_win = vim.api.nvim_get_current_win()
	state.tree_buf = vim.api.nvim_get_current_buf()

	vim.api.nvim_win_set_width(state.tree_win, 36)

	vim.bo[state.tree_buf].buftype = "nofile"
	vim.bo[state.tree_buf].bufhidden = "hide"
	vim.bo[state.tree_buf].swapfile = false
	vim.bo[state.tree_buf].filetype = "prreviewtree"
	vim.bo[state.tree_buf].modifiable = false
	vim.bo[state.tree_buf].buflisted = false

	vim.wo[state.tree_win].number = false
	vim.wo[state.tree_win].relativenumber = false
	vim.wo[state.tree_win].signcolumn = "no"
	vim.wo[state.tree_win].cursorline = true
	vim.wo[state.tree_win].winfixwidth = true

	return state.tree_win, state.tree_buf
end

local function apply_review_base(bufnr)
	local base = state.base or vim.g.pr_review_base
	if not base or base == "" then
		return
	end

	vim.defer_fn(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		local ok, gs = pcall(require, "gitsigns")
		if not ok then
			return
		end

		-- Run in the context of the opened buffer
		vim.api.nvim_buf_call(bufnr, function()
			gs.change_base(base)
			gs.refresh()
		end)
	end, 80)
end

local function open_file_from_tree()
	local buf = state.tree_buf
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local line = vim.api.nvim_win_get_cursor(0)[1]
	local node = vim.b[buf].line_map and vim.b[buf].line_map[line]
	if not node or not node.is_file then
		return
	end

	local fullpath = state.root .. "/" .. node.path

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= state.tree_win then
			local wbuf = vim.api.nvim_win_get_buf(win)
			if vim.bo[wbuf].filetype ~= "prreviewtree" then
				vim.api.nvim_set_current_win(win)
				vim.cmd("edit " .. vim.fn.fnameescape(fullpath))
				apply_review_base(vim.api.nvim_get_current_buf())
				return
			end
		end
	end

	vim.cmd("wincmd l")
	vim.cmd("edit " .. vim.fn.fnameescape(fullpath))
	apply_review_base(vim.api.nvim_get_current_buf())
end

local function render_tree()
    local _, buf = ensure_tree_window()
    local tree = build_tree(state.files)
	local lines, highlights, line_map = flatten_tree(tree)

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_set_name(buf, "PR Review Tree")

	-- apply highlights
	for _, h in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(buf, -1, h.hl, h.line, 0, -1)
	end

	vim.b[buf].line_map = line_map
	vim.b[buf].pr_review_base = state.base

	local opts = { buffer = buf, silent = true, nowait = true }
	vim.keymap.set("n", "<CR>", open_file_from_tree, opts)
	vim.keymap.set("n", "o", open_file_from_tree, opts)
	vim.keymap.set("n", "q", function()
		if state.tree_win and vim.api.nvim_win_is_valid(state.tree_win) then
			vim.api.nvim_win_close(state.tree_win, true)
		end
	end, opts)
	vim.keymap.set("n", "R", function()
		state.files = changed_files(state.base, state.root)
		render_tree()
	end, opts)
end

local function set_base(base)
	state.base = base
	vim.g.pr_review_active = true
	vim.g.pr_review_base = base
	vim.notify("PR review base: " .. base, vim.log.levels.INFO)
end

function M.start(base)
	state.root = git_root()
	if not state.root then
		return
	end

	set_base(base)
	state.files = changed_files(base, state.root)
	render_tree()
end

function M.pick_base_and_open_tree()
	local bases = default_base_candidates()
	vim.ui.select(bases, { prompt = "Select PR review base" }, function(base)
		if not base or base == "" then
			return
		end
		M.start(base)
	end)
end

function M.refresh()
	if not state.base or not state.root then
		vim.notify("PR review not initialized", vim.log.levels.WARN)
		return
	end
	state.files = changed_files(state.base, state.root)
	render_tree()
end

function M.change_base()
	local bases = default_base_candidates()
	vim.ui.select(bases, { prompt = "Change PR review base" }, function(base)
		if not base or base == "" then
			return
		end
		M.start(base)
	end)
end

return M
