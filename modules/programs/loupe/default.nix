{ lib, ... }:
let
  inherit (lib) singleton;
  inherit (lib.x) genMimes;
in
{

  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      hj.packages = singleton pkgs.loupe;
      hj.xdg.mime-apps = genMimes "org.gnome.Loupe.desktop" [
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/heic"
        "image/heif"
        "image/jpeg"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/vnd.microsoft.icon"
        "image/webp"
      ];
    };
}
