{ lib, ... }:
let
  inherit (lib) toList escapeShellArg;
  appId = "org.equicord.equibop";
  readonly =
    default:
    lib.mkOption {
      inherit default;
      type = lib.types.singleLineStr;
      readOnly = true;
    };
in
{
  perSystem = { pkgs, ... }: {
    packages.equibop = pkgs.writeShellScriptBin "equibop" /* bash */ ''
      exec -a "equibop" flatpak run -- ${escapeShellArg appId} "$@"
    '';
  };

  flake.modules.nixos.gui = {
    options.programs.discord.appId = readonly appId;
    config = {
      services.flatpak = {
        packages = toList appId;
        overrides.settings = {
          "${appId}".Context.filesystems = [
            "xdg-config/equibop"
            "!xdg-config"
            "!xdg-data"
            "!xdg-videos"
            "!xdg-pictures"
            "!xdg-music"
          ];
        };
      };

      systemd.user.tmpfiles.rules = [
        "L+ %t/discord-ipc-0 - - - - %t/.flatpak/org.equicord.equibop/xdg-run/discord-ipc-0"
      ];

      home.xdg.mime-apps = lib.x.genMimes "equibop.desktop" [ "x-scheme-handler/discord" ];
      home.xdg.config.files."equibop/settings/settings.json" = {
        type = "copy";
        permissions = "644";
        generator = builtins.toJSON;
        value = import ./_settings.nix;
      };
    };
  };
}
