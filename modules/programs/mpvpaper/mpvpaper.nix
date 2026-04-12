{ self, ... }:
{

  flake.modules.homeManager.gui =
    {
      pkgs,
      system,
      ...
    }:
    {
      home.packages = with pkgs; [ mpvpaper ];

      wayland.windowManager.hyprland.settings.bind = [
        "$mainMod, W, exec, ${self.packages.${system}.wallpaper}/bin/wallpaper"
      ];

      systemd.user.services.mpvpaper-daemon = {
        Unit = {
          Description = "mpvpaper control daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${self.packages.${system}.mpvpaper-daemon}/bin/mpvpaper-daemon";
          Restart = "on-failure";
          RestartSec = 10;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
