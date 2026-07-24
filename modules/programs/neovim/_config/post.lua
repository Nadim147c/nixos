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

local function expand_go_err()
  local cword = vim.fn.expand("<cword>")
  if cword ~= "err" then
    local found = vim.fn.search([[\<err\>]], "c", vim.fn.line("."))
    if found == 0 then
      vim.notify("No 'err' found on current line", vim.log.levels.WARN)
      return
    end
  end

  local method_prefix = ""

  local node = vim.treesitter.get_node()

  while node do
    local ntype = node:type()
    print(ntype)
    if ntype == "function_declaration" or ntype == "method_declaration" then
      -- Get function/method name
      local name_node = node:field("name")[1]
      local method_name = name_node and vim.treesitter.get_node_text(name_node, 0) or "Func"

      local receiver_node = node:field("receiver")[1]
      local type_name = ""
      if receiver_node then
        local rec_text = vim.treesitter.get_node_text(receiver_node, 0)
        type_name = rec_text:match("%*?(%w+)%s*%)$") or ""
      end

      if type_name ~= "" then
        method_prefix = type_name .. "." .. method_name
      else
        method_prefix = method_name
      end
      break
    end
    node = node:parent()
  end

  if method_prefix ~= "" then
    method_prefix = method_prefix .. ":"
  end

  local replacement = string.format('fmt.Errorf("%s : %%w", err)', method_prefix)
  vim.cmd("normal! ciw" .. replacement)

  local search_pattern = method_prefix .. " "
  vim.fn.search(search_pattern, "b", vim.fn.line("."))
  vim.cmd("normal! " .. #search_pattern .. "l")
  vim.cmd("startinsert")
end

-- Keymap registration for Go buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.keymap.set("n", "<leader>ge", expand_go_err, {
      buffer = true,
      desc = "Wrap 'err' in fmt.Errorf with method context",
    })
  end,
})
