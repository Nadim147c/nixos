{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) const concatMapStringsSep optionalString;
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
        # runShell = singleton /* bash */ ''
        #   ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6
        # '';
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

      preserveHome.files = singleton ".local/state/dolphinstaterc";

      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      home.xdg.config.files."dolphinrc".text = ''
        [UiSettings]
        ColorScheme=Rong
      '';

      home.xdg.data.files."user-places.xbel" = {
        generator =
          { bookmarks }:
          let
            renderBookmark =
              {
                name,
                icon ? "inode-directory",
                path ? null,
                url ?
                  if (path != null) then
                    "file://${path}"
                  else
                    throw "makeUserPlaces: Either 'url' or 'path' must be specified for bookmark '${name}'",
              }:
              ''
                <bookmark href="${url}">
                  <title>${name}</title>
                  <info>
                    <metadata owner="http://freedesktop.org">
                      <bookmark:icon name="${icon}"/>
                    </metadata>
                  </info>
                </bookmark>
              '';

          in
          ''
            <?xml version="1.0" encoding="UTF-8"?>
            <xbel xmlns:bookmark="http://videoelan.org/xml/xbel/">
              ${concatMapStringsSep "\n  " renderBookmark bookmarks}
            </xbel>
          '';
      };
    };
}
