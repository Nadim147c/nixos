{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkIf concatMapStringsSep singleton;
  inherit (builtins) isBool;
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

      application-menu = pkgs.runCommand "application-menu" { } ''
        mkdir -p $out/etc/xdg/menus/
        cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out/etc/xdg/menus/applications.menu
      '';
    in
    {
      packages.dolphin =
        mkIf pkgs.stdenv.hostPlatform.isLinux
        <| inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.kdePackages.dolphin;
          runShell = singleton /* bash */ ''
            rm -vrf ~/.cache/ksycoca6*
            ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6
          '';
          prefixVar = [
            (makePrefix "PATH" "/run/wrappers:/run/current-system/sw/bin")
            (makePrefix "XDG_CONFIG_DIRS" "${application-menu}/etc/xdg")
            (makeQtPluginPrefix dependencies)
          ];
        };
    };

  flake.modules.nixos.base =
    { system, ... }:
    {
      packages = singleton self.packages.${system}.dolphin;

      hj.xdg.config.files."dolphinrc".text = ''
        [UiSettings]
        ColorScheme=Rong
      '';

      hj.xdg.mime-apps = lib.x.genMimes "org.kde.dolphin.desktop" [ "inode/directory" ];

      hj.xdg.data.files."user-places.xbel" = {
        type = "copy";
        permissions = "644";
        generator =
          { bookmarks }:
          let
            renderBookmark =
              {
                name,
                icon ? "inode-directory",
                hidden ? false,
                path ? null,
                url ?
                  if (path != null) then
                    "file://${path}"
                  else
                    throw "makeUserPlaces: Either 'url' or 'path' must be specified for bookmark '${name}'",
              }:
              assert (isBool hidden);
              ''
                <bookmark href="${url}">
                  <title>${name}</title>
                  <info>
                    <metadata owner="http://freedesktop.org">
                      <bookmark:icon name="${icon}"/>
                    <IsHidden>${builtins.toJSON hidden}</IsHidden>
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
