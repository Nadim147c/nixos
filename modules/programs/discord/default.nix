{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.lists) singleton;
in
{
  perSystem = { pkgs, ... }: {
    packages.discord-sandboxxed = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      wrapperVariants."discord".runShell = singleton "cd /tmp";
      passthru.meta.mainProgram = "discord";
      filesToExclude = singleton "bin/Discord";
      package = pkgs.mkBwrapper {
        imports = singleton pkgs.bwrapperPresets.desktop;
        app = {
          package = pkgs.discord.override {
            withOpenASAR = true;
            withEquicord = true;
            useFHSEnv = false;
          };
          id = "com.discordapp.Discord";
          isFhsenv = true;
        };
        sockets.x11 = false;
        mounts = {
          readWrite = [
            "$XDG_RUNTIME_DIR/app/com.discordapp.Discord"
            "$XDG_RUNTIME_DIR/speech-dispatcher"
            "$XDG_CONFIG_HOME/discord"
            "$XDG_CONFIG_HOME/equicord"
            {
              from = "$XDG_DOWNLOAD_DIR";
              to = "$XDG_DOWNLOAD_DIR/discord";
            }
          ];
        };
        dbus.session.talks = [
          "org.freedesktop.ScreenSaver"
          "org.kde.StatusNotifierWatcher"
          "com.canonical.AppMenu.Registrar"
          "com.canonical.indicator.application"
          "com.canonical.Unity"
        ];
        dbus.system.talks = [
          "org.freedesktop.UPower"
        ];
        dbus.session.owns = [
          "com.discordapp.Discord"
        ];
      };
    };
  };
  flake.modules.nixos.gui =
    { system, ... }:
    let
      inherit (self.packages.${system}) control discord-sandboxxed;
    in
    {
      preserveHome.directories = [
        ".config/discord"
        ".config/Equicord"
      ];

      hj.programs.hyprland = {
        windowRules = singleton {
          name = "discord workspace 3";
          match.class = "^(discord)$";
          workspace = "3 silent";
        };
        programs = singleton {
          keys = [
            "SUPER"
            "D"
          ];
          autostart = true;
          exec = "${getExe control} --memory=800M --cpu=80% ${getExe discord-sandboxxed}";
        };
      };

      packages = singleton discord-sandboxxed;

      hj.xdg.mime-apps = lib.x.genMimes "discord.desktop" [ "x-scheme-handler/discord" ];
      hj.systemd.services.update-discord-settings = {
        enable = true;
        restartTriggers = [ ./settings.json ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = false;
        };
        wantedBy = [
          "default.target"
          "sysinit-reactivation.target"
        ];
        before = singleton "sysinit-reactivation.target";
        script = ''
          set -eu

          OUT="$HOME/.config/Equicord/settings/settings.json"
          TMP=$(mktemp)

          cleanup() {
            rm -f "$TMP"
          }
          trap cleanup EXIT

          if ! jq empty ${./settings.json}; then
            echo "error: ${./settings.json} contains invalid JSON" >&2
            exit 1
          fi

          if [ -f "$OUT" ] && jq empty "$OUT" 2>/dev/null; then
            jq -s '.[0] * .[1]' "$OUT" ${./settings.json} > "$TMP"
          else
            jq -s '.[0] * .[1]' <(printf '{}') ${./settings.json} > "$TMP"
          fi

          install -Dm644 "$TMP" "$OUT"
        '';
      };
    };
}
