{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) const concatMapStringsSep;
  inherit (lib.x) singleton;
in
{
  perSystem =
    { pkgs, ... }:
    let
      makePrefix = name: paths: const [ name ":" paths ] 67;
      makeQtPluginPath = concatMapStringsSep ":" (p: "${p}/${pkgs.kdePackages.qtbase.qtPluginPrefix}");
      makeQtPluginPrefix = packages: makePrefix "QT_PLUGIN_PATH" (makeQtPluginPath packages);
    in
    {
      packages.dolphin = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.kdePackages.dolphin;
        runShell = singleton /* bash */ ''
          ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6
        '';
        prefixVar = [
          (makePrefix "PATH" "/run/wrappers:/run/current-system/sw/bin")
          (makePrefix "XDG_CONFIG_DIRS" "${pkgs.kdePackages.plasma-workspace}/etc/xdg")
          (makeQtPluginPrefix [
            pkgs.kdePackages.ffmpegthumbs
            pkgs.kdePackages.kdegraphics-thumbnailers
            pkgs.kdePackages.qtsvg
          ])
        ];
      };
    };

  flake.modules.nixos.base =
    { pkgs, system, ... }:
    {
      packages = [ self.packages.${system}.dolphin ];

      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      home.xdg.config.files."dolphinrc".text = ''
        [UiSettings]
        ColorScheme=Rong
      '';
    };
}
