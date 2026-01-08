-- use columnar file explorer by default, and
-- demote vscode-style to fe/fE shortcuts
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    opts = {
      window = {
        mappings = {
          ['<leader>e'] = 'none',
          ['<leader>E'] = 'none',
        },
      },
    },
  },
  {
    'nvim-mini/mini.files',
    keys = {
      {
        '<leader>E',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'Open mini.files (directory of current file)',
      },
      {
        '<leader>e',
        function()
          require('mini.files').open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    opts = {
      windows = {
        width_focus = 35,
        width_preview = 45,
      },
      options = {
        use_as_default_explorer = true,
      },
    },
  },
}
