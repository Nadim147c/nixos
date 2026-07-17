# Copied from https://github.com/NotAShelf/nyx/blob/d407b4d6e5ab7f60350af61a3d73a62a5e9ac660/modules/core/common/system/security/impurity-tracker.nix
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      makeTracker =
        name: target: exe:
        pkgs.writeShellScript name ''
          PNAME=$(cat /proc/$PPID/comm 2>/dev/null || echo "unknown")

          echo "Program [$PNAME] (PID $PPID) executed ${target}" |& ${config.systemd.package}/bin/systemd-cat --identifier=impurity >/dev/null 2>/dev/null
          exec -a "$0" '${exe}' "$@"
        '';
    in
    {
      environment = {
        usrbinenv = makeTracker "env" "/usr/bin/env" "${pkgs.coreutils}/bin/env";
        binsh = makeTracker "sh" "/bin/sh" "${pkgs.bashInteractive}/bin/sh";
      };
    };
}
