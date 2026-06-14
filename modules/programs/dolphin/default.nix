{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.x) singleton;
in
{
  perSystem =
    { pkgs, ... }:
    let
      makePathPrefix = name: paths: [
        name
        ":"
        paths
      ];
    in
    {
      packages.dolphin = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.kdePackages.dolphin;
        runShell = singleton /* bash */ ''
          ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6
        '';
        prefixVar = [
          (makePathPrefix "PATH" "/run/wrappers:/run/current-system/sw/bin")
          (makePathPrefix "XDG_CONFIG_DIRS" "${pkgs.kdePackages.plasma-workspace}/etc/xdg")
        ];
      };
    };

  flake.modules.nixos.base =
    { pkgs, system, ... }:
    {
      packages = with pkgs.kdePackages; [
        self.packages.${system}.dolphin
        ffmpegthumbs
        kdegraphics-thumbnailers
        qtsvg
      ];

      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      home.xdg.config.files."dolphinrc".text = ''
        [UiSettings]
        ColorScheme=Rong
      '';
    };
}
