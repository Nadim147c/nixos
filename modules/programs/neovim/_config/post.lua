vim.g.has_ui = #vim.api.nvim_list_uis() > 0
vim.g.has_gui = vim.g.has_ui and (vim.env.DISPLAY ~= nil or vim.env.WAYLAND_DISPLAY ~= nil)

if not vim.g.has_gui then
  if vim.g.has_ui then
    vim.o.termguicolors = false
    vim.cmd.colorscheme("default")
  end
  return
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  desc = "Highlight selection on yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 200, visual = true })
  end,
})

-- remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "silent! %s/\\s\\+$//e",
})

-- save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa",
})

-- absolute line numbers in insert mode, relative otherwise
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  command = "set number norelativenumber",
})
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set number relativenumber",
})
