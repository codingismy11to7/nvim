-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

vim.o.exrc = true

-- Workaround: exrc doesn't load automatically with Nix-managed neovim
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local cwd = vim.fn.getcwd()
    for _, name in ipairs({ ".nvim.lua", ".nvimrc", ".exrc" }) do
      local exrc = cwd .. "/" .. name
      if vim.fn.filereadable(exrc) == 1 then
        vim.cmd.source(exrc)
        return
      end
    end
  end,
})
