{
  config,
  ...
}:
let
  inherit (config) username;
in
{
  flake.modules.nixos.pc =
    { config, ... }:
    {
      services.displayManager = {
        autoLogin.user = username;
        defaultSession = "hyprland";
        ly = {
          enable = true;
          settings = {
            bigclock = "en";
            save = false; # don't use previous successful session
            session_log = "${config.home.xdg.data.directory}/ly-session.log";
          };
        };
      };
    };
}
