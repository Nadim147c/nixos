{
  lib,
  ...
}:
let
  inherit (lib.lists) singleton;
  appId = "net.lrclib.lrcget";
in
{
  flake.modules.nixos.gui = {
    services.flatpak = {
      packages = singleton {
        inherit appId;
      };
      overrides.settings."${appId}" = {
        Context.filesystems = [
          "xdg-config/lrcget"
          "xdg-music"
        ];
        Environment = {
          GTK_CSD = "0";
        };
      };
    };
  };
}
