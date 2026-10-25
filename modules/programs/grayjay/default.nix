{
  config,
  self,
  lib,
  ...
}:
let
  inherit (lib.lists) singleton;

  appId = "app.grayjay.Grayjay";
in
{
  flake.tree.nixos.gui.grayjay = {
    services.flatpak = {
      packages = singleton appId;
      overrides.settings."${appId}" = {
        Context.filesystems = singleton "xdg-download";
      };
    };
  };
}
