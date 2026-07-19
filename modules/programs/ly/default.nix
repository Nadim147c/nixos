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
        # Don't use autologin
        # autoLogin.user = username;
        defaultSession = "hyprland";
        ly = {
          enable = true;
          settings = {
            bigclock = "en";
            save = true;
          };
        };
      };
    };
}
