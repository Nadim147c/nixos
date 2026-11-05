{ lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
in
{
  flake.tree.nixos.gui.prism-download-manager =
    { self', ... }:
    {
      packages = singleton self'.packages.prism-download-manager;

      hj.programs.hyprland.programs = singleton {
        autostart = true;
        exec = "${getExe self'.packages.control} --memory=700M --cpu=200% ${getExe self'.packages.prism-download-manager} --background";
      };
    };
}
