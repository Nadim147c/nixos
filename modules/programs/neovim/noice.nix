{
  flake.modules.neovim.base.vim = {
    ui.noice = {
      enable = true;
      setupOpts = {
        cmdline = {
          enabled = true;
          view = "cmdline_popup";
        };

        messages.enabled = true;
        popupmenu.enabled = false;

        redirect = {
          view = "popup";
          filter.event = "msg_show";
        };

        notify = {
          enabled = true;
          view = "notify";
        };

        lsp = {
          progress = {
            enabled = true;
            format = "lsp_progress";
            format_done = "lsp_progress_done";
            throttle = 1000 / 30;
            view = "mini";
          };
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = false;
            "vim.lsp.util.stylize_markdown" = false;
            "cmp.entry.get_documentation" = false;
          };
          hover.enabled = false;
        };

        health.checker = true;

        presets = {
          bottom_search = false;
          command_palette = false;
          long_message_to_split = false;
          inc_rename = false;
          lsp_doc_border = false;
        };

        throttle = 1000 / 30;
      };
    };
  };
}
