{
  flake.modules.neovim.base.vim = {
    comments.comment-nvim = {
      enable = true;
      mappings = {
        toggleSelectedLine = "<leader>/";
        toggleCurrentLine = "<leader>/";
      };
    };
  };
}
