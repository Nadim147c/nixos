{ pkgs, lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  vim = {
    viAlias = true;
    vimAlias = true;

    theme = {
      enable = true;
      transparent = true;
      name = "tokyonight";
      style = "moon";
    };

    extraPlugins =
      let
        inherit (pkgs.vimPlugins) direnv-vim nvim-surround;
      in
      {
        direnv.package = direnv-vim;
        nvim-surrond.package = nvim-surround;
      };

    # autocmds
    luaConfigPost = builtins.readFile ./post.lua;

    autopairs.nvim-autopairs.enable = true;
    binds.whichKey.enable = true;
    mini = {
      align.enable = true;
      indentscope.enable = true;
    };

    git.enable = true;

    lazy.enable = true;
    snippets.luasnip.enable = true;
    statusline.lualine.enable = true;

    ui = {
      smartcolumn.enable = true;
      colorizer.enable = false;
    };
    utility = {
      undotree.enable = true;
      motion.leap.enable = true;
      sleuth.enable = true;
      snacks-nvim = {
        enable = true;
        setupOpts = {
          image = {
            enabled = true;
            inline = true;
          };
          picker.enabled = false;
          dashboard.enabled = false;
          bigfile.enabled = true;
          indent.enabled = true;
          input.enabled = true;
          notifier.enabled = true;
          quickfile.enabled = true;
          scroll.enabled = true;
          statuscolumn.enabled = true;
          words.enabled = true;
        };
      };
    };
    visuals.nvim-web-devicons.enable = true;
  };
}
