-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Force a high-contrast cursor so the character underneath stays legible,
-- regardless of what fg/bg the colorscheme picks for the token under it.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("fix_cursor_contrast", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#ffffff" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#ffffff" })
  end,
})
