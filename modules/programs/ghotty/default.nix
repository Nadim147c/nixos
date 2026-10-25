{ self, lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.x) opt;
in
{
  flake.wrappers.ghostty =
    {
      config,
      wlib,
      pkgs,
      ...
    }:
    let
      # fallback theme
      tokyo-night = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/cdc07ac78467a233fd62c493de29a17e0cf2b2b6/extras/ghostty/tokyonight_moon";
        hash = "sha256-Hht3TDSuz8Zi1CtforNRpwdmccC72kabm8gI4mlVWb8=";
      };
    in
    {
      imports = [ wlib.wrapperModules.ghostty ];
      options.theme = opt.str "${tokyo-night}";
      config = {
        flags."--config-file" = config.theme;
        flagSeparator = "=";
        settings = {
          font-family = "JetBrainsMono Nerd Font";
          font-size = 12;
          command = getExe pkgs.fish;
          window-vsync = false;
          window-padding-x = 5;
          window-padding-y = 5;
          confirm-close-surface = false;
          keybind = [
            "ctrl+minus=decrease_font_size:1"
            "ctrl+equal=increase_font_size:1"
            "performable:ctrl+c=copy_to_clipboard"
            "ctrl+v=paste_from_clipboard"
          ];
        };
      };
    };

  flake.tree.nixos.gui.ghostty =
    { config, pkgs, ... }:
    {
      imports = [ self.wrappers.ghostty.install ];

      packages = singleton pkgs.nerd-fonts.jetbrains-mono;

      wrappers.ghostty = {
        enable = true;
        theme = "${config.hj.xdg.state.directory}/rong/ghostty-full";
      };
    };
}
