{
  createLuaKeymap,
  better-iferr,
  lib,
  ...
}:
let
  inherit (lib) getExe;
in
{
  vim = {
    keymaps = [
      (createLuaKeymap "n" "<leader>e" /* lua */ ''
        function ()
          local bufnr = vim.api.nvim_get_current_buf()
          local winnr = vim.api.nvim_get_current_win()

          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename == "" then
            filename = "main.go" -- Fallback if buffer is unsaved/unnamed
          end

          local byte_offset = vim.fn.line2byte(vim.fn.line('.')) + vim.fn.col('.') - 2
          if byte_offset < 0 then byte_offset = 0 end

          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local input_content = table.concat(lines, "\n")

          local cmd = { "${getExe better-iferr}", "-f", filename, "-p", tostring(byte_offset) }
          local output = vim.fn.system(cmd, input_content)

          if vim.v.shell_error ~= 0 then
            vim.notify("Error running code generator:\n" .. output, vim.log.levels.ERROR)
            return
          end

          local output_lines = vim.split(output, "\n", { trimempty = false })

          if output_lines[#output_lines] == "" then
            table.remove(output_lines)
          end

          if #output_lines > 0 then
            local cursor_row = vim.api.nvim_win_get_cursor(winnr)[1] -- 1-indexed current line

            vim.api.nvim_buf_set_lines(bufnr, cursor_row, cursor_row, false, output_lines)

            vim.api.nvim_win_set_cursor(winnr, { cursor_row + 1, 0 })
            vim.cmd [[silent normal! =2j]]
          end
        end
      '')
    ];
  };
}
