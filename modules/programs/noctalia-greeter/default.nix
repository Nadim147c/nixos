{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config) username;
  inherit (lib) singleton;
in
{
  flake.modules.nixos.gui = { pkgs, ... }: {
    imports = singleton inputs.noctalia-greeter.nixosModules.default;

    preserve.directories = singleton "/var/lib/noctalia-greeter";
    services.greetd = {
      enable = true;
      settings.default_session.user = username;
    };
    programs.noctalia-greeter = {
      enable = true;
      greeter-args = "";
      settings = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard = {
          layout = "us";
        };
      };
    };
  };
}
