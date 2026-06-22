{ lib, ... }:
let
  inherit (lib) toList escapeShellArg;
  appId = "org.equicord.equibop";

  readonly =
    name:
    lib.mkOption {
      type = lib.types.singleLineStr;
      readOnly = true;
      default = name;
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.equibop = pkgs.writeShellScriptBin "equibop" /* bash */ ''
        exec -a "equibop" flatpak run -- ${escapeShellArg appId} "$@"
      '';
    };

  flake.modules.nixos.gui =
    { config, ... }:
    {
      options.programs.discord.appId = readonly appId;
      config = {
        services.flatpak = {
          packages = toList appId;
          overrides.settings."${appId}".Context.filesystems = [
            "xdg-config/equibop"
            "xdg-music"
          ];
        };

        programs.rong.settings.links."midnight-discord.css" = [
          "${config.home.xdg.config.directory}/equibop/settings/quickCss.css"
        ];

        home.xdg.mime-apps = lib.x.genMimes "equibop.desktop" [ "x-scheme-handler/discord" ];
      };
    };
}
