{
  lib,
  self,
  inputs,
  ...
}:
{

  flake.modules.homeManager.gui =
    {
      config,
      pkgs,
      ...
    }:
    {
      programs.rong.settings.themes = lib.toList {
        target = "kitty-full.conf";
        links = "${config.xdg.configHome}/kitty/colors.conf";
        cmds = "${lib.getExe' pkgs.procps "pkill"} -SIGUSR1 kitty";
      };

      home.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
      programs.kitty = {
        enable = true;
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 10;
        };
        extraConfig = /* bash */ ''
          include colors.conf
        '';
        settings = {
          shell = lib.getExe pkgs.fish;
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
}
