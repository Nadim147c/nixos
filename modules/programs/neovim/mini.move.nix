{
  flake.modules.neovim.base.vim = {
    mini.move = {
      enable = true;
      setupOpts = {
        options = {
          reindent_linewise = true;
        };
        mappings = {
          left = "H";
          right = "L";
          down = "J";
          up = "K";
        };
      };
    };
  };
}
