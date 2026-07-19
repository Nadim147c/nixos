{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) concatMapStringsSep optionalString singleton;
in
{
  perSystem =
    { pkgs, ... }:
    let
      makePrefix = name: paths: [
        name
        ":"
        paths
      ];
      makeQtPluginPath = concatMapStringsSep ":" (p: "${p}/${pkgs.kdePackages.qtbase.qtPluginPrefix}");
      makeQtPluginPrefix = packages: makePrefix "QT_PLUGIN_PATH" (makeQtPluginPath packages);

      dependencies = with pkgs.kdePackages; [
        ffmpegthumbs
        kdegraphics-thumbnailers
        qtsvg
      ];
    in
    {
      packages.dolphin = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.kdePackages.dolphin;
        prefixVar = [
          (makePrefix "PATH" "/run/wrappers:/run/current-system/sw/bin")
          (makePrefix "XDG_CONFIG_DIRS" "${pkgs.kdePackages.plasma-workspace}/etc/xdg")
          (makeQtPluginPrefix dependencies)
        ];
      };
    };

  flake.modules.nixos.base =
    { pkgs, system, ... }:
    {
      packages = singleton self.packages.${system}.dolphin;

      preserveHome.files = singleton ".local/state/dolphinstaterc";

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
