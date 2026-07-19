{ lib, ... }:
let
  inherit (lib) fix getExe singleton;
in
{
  perSystem = { pkgs, ... }: {
    packages.mpvpaper-send-ipc = pkgs.writeShellScriptBin "mpvpaper-send-ipc" ''
      echo "$1" | ${getExe pkgs.socat} - "$XDG_RUNTIME_DIR/mpvpaper.sock"
    '';
  };

  flake.modules.nixos.gui = { pkgs, ... }: {
    packages = with pkgs; [ mpvpaper ];
    preserveHome.directories = singleton ".local/state/wallpaper";

    home.systemd.paths.mpvpaper-watcher = fix (final: {
      enable = true;
      description = "Watch wallpaper-state for atomic changes";
      partOf = singleton "graphical-session.target";
      wantedBy = final.partOf;
      unitConfig = {
        ConditionEnvironment = "XDG_RUNTIME_DIR";
      };
      pathConfig = {
        PathChanged = "%h/.local/state/wallpaper/state";
        Unit = "mpvpaper-watcher.service";
      };
    });

    home.systemd.services.mpvpaper-watcher = {
      enable = true;
      description = "Send new wallpaper path to mpvpaper IPC socket";
      unitConfig = {
        ConditionEnvironment = "XDG_RUNTIME_DIR";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "mpvpaper-send-ipc" ''
          STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/state"
          SOCKET="$XDG_RUNTIME_DIR/mpvpaper.sock"

          if [ -S "$SOCKET" ] && [ -f "$STATE_FILE" ]; then
            printf "loadfile %q\n" "$(cat "$STATE_FILE")" | ${getExe pkgs.socat} - "$SOCKET"
          fi
        '';
      };
    };

    home.systemd.services.mpvpaper = fix (final: {
      enable = true;
      description = "Mpvpaper daemon";
      partOf = singleton "graphical-session.target";
      after = final.partOf;
      wantedBy = final.partOf;
      unitConfig = {
        ConditionEnvironment = "XDG_RUNTIME_DIR";
      };
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "mpvpaper-start" ''
          WALLPAPER=$(cat "''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/state")
          exec ${getExe pkgs.mpvpaper} \
            -o "loop panscan=1.0 background-color='#222222' mute=yes config=no input-ipc-server=$XDG_RUNTIME_DIR/mpvpaper.sock" \
            "*" "$WALLPAPER"
        '';
        Restrart = "always";
        RestartSec = 10;
      };
    });
  };
}
