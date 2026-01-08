-- this plugin was crashing lualine, but turning off lazy loading seems to fix it.
-- i guess revisit later?
return {
  {
    'folke/trouble.nvim',
    lazy = false,
  },
}
