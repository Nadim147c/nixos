{ inputs, self, ... }:
{

  flake.modules.homeManager.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      discord-voice-rpc = pkgs.lib.flakePackage inputs.discord-voice-rpc;
      qtLibs = with pkgs; [
        waybar-lyric
        qt6.qtimageformats
        qt6.qtmultimedia
        qt6.qtsvg
        self.packages.${system}.qt-m3shapes
      ];
    in
    {
      home.packages = with pkgs; [
        kdePackages.qt5compat
        kdePackages.qtdeclarative
        discord-voice-rpc
      ];

      xdg.configFile."quickshell".source = ./.;

      programs.rong.settings.installs = {
        "quickshell.json" = "${config.xdg.stateHome}/quickshell/colors.json";
      };

      programs.quickshell = {
        enable = true;
        package = (pkgs.lib.flakePackage inputs.quickshell).overrideAttrs (oldAttrs: {
          buildInputs = qtLibs ++ oldAttrs.buildInputs;
        });
        systemd.enable = true;
      };

      wayland.windowManager.hyprland.settings.bind = [
        "$mainMod, V, exec, qs-toggle clipboard toggle"
        "$mainMod, SPACE, exec, qs-toggle launcher toggle"
      ];
    };
}
