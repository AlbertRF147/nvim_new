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
        function() require("mini.bufremove").delete(0, false) end,
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
        theme = "catppuccin",
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
      }
    }
  }
}
