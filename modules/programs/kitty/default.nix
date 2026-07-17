{
  self,
  inputs, lib,
  ...
}:
let
  inherit (lib) getExe toList;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kitty = inputs.wrappers.wrappers.kitty.wrap {
        inherit pkgs;
        package = pkgs.kitty;
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 10;
        };
        extraConfig = /* bash */ ''
          include ~/.config/kitty/colors.conf
        '';
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
        };
      };
    };

  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      programs.rong.settings.themes = toList {
        target = "kitty-full.conf";
        links = "${config.home.xdg.config.directory}/kitty/colors.conf";
        cmds = pkgs.writers.writeNu "reload-kitty" /* nu */ ''
          let pids = ps | find kitty | get pid
          if ($pids | is-not-empty) {
            kill -s 10 ...$pids
          }
        '';
      };

      packages = [
        pkgs.nerd-fonts.jetbrains-mono
        self.packages.${system}.kitty
      ];
    };
}
