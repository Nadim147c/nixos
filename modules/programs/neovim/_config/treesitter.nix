{ pkgs, ... }:
{
  vim = {
    treesitter.indent.enable = false;
    treesitter.grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    treesitter.autotagHtml = true;
    treesitter.textobjects = {
      enable = true;
      setupOpts = {
        lookahead = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
        };
        selection_modes = {
          "@parameter.outer" = "v"; # charwise
          "@function.outer" = "V"; # linewise
          "@class.outer" = "<c-v>"; # blockwise
        };
        include_surrounding_whitespace = true;
      };
    };
  };
}
