{
  flake.modules.neovim.base.vim = {
    tabline.nvimBufferline = {
      enable = true;
      mappings = {
        closeCurrent = "<leader>x";
        cycleNext = "<Tab>";
        cyclePrevious = "<S-Tab>";
      };

      setupOpts.options = {
        show_close_icon = true;
      };
    };
  };
}
