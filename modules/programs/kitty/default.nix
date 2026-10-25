{ self, lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.x) opt;
in
{
  flake.wrappers.kitty =
    {
      config,
      wlib,
      pkgs,
      ...
    }:
    let
      # fallback theme
      tokyo-night = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/cdc07ac78467a233fd62c493de29a17e0cf2b2b6/extras/kitty/tokyonight_moon.conf";
        hash = "sha256-F2mcDp1HI/RLRjEpAABRCfrCsJTcEhbsUE02bTKEBDA=";
      };
    in
    {
      imports = [ wlib.wrapperModules.kitty ];
      options.theme = opt.str "${tokyo-night}";
      config = {
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 10;
        };
        extraConfig = "include ${config.theme}";
        settings = {
          shell = getExe pkgs.fish;
          bold_font = "auto";
          italic_font = "auto";
          bold_italic_font = "auto";
          sync_to_monitor = "no";
          window_margin_width = "5";
          cursor_trail = "1";
          confirm_os_window_close = "0";
        };
        keybindings = {
          "ctrl+minus" = "change_font_size all -0.5";
          "ctrl+=" = "change_font_size all +0.5";
          "ctrl+c" = "copy_or_interrupt";
          "ctrl+v" = "paste_from_clipboard";
          "ctrl+e" = "copy_ansi_to_clipboard";
        };
      };
    };

  flake.tree.nixos.gui.kitty =
    {
      config,
      pkgs,
      self',
      ...
    }:
    {
      imports = [ self.wrappers.kitty.install ];

      packages = singleton pkgs.nerd-fonts.jetbrains-mono;

      hj.programs.hyprland = {
        programs =
          let
            launcher = getExe self'.packages.control;
            kitty = getExe config.wrappers.kitty.wrapper;
          in
          [
            {
              keys = [
                "SUPER"
                "Q"
              ];
              exec = "${launcher} ${kitty}";
            }
            {
              autostart = true;
              exec = "sleep 10 && ${launcher} ${kitty}";
            }
          ];
      };

      wrappers.kitty = {
        enable = true;
        theme = "${config.hj.xdg.state.directory}/rong/kitty-full.conf";
      };
    };
}
