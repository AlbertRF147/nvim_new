local map = vim.keymap.set

-- Escape shortcuts
map("i", "jj", "<Esc>")
map("v", "<C-c><C-c>", "<Esc>")

-- Dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Better Movement & Editing
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "J", "mzJ`z", { desc = "Join lines steady cursor" })

-- Center view on scroll/search
-- map("n", "<C-d>", "<C-d>zz")
-- map("n", "<C-u>", "<C-u>zz")
-- map("n", "n", "nzzzv")
-- map("n", "N", "Nzzzv")

-- Clipboard Management
map("x", "p", [["_dP]], { desc = "Paste without overwriting register" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Convenience
map("n", "<leader>s", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>ss", "<cmd>so<CR>", { desc = "Source file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Exit" })
map("n", "<leader><space>", "<C-^>", { desc = "Swap buffer" })
