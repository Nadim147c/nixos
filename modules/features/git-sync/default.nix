{ lib, ... }:
let
  inherit (lib) getExe;
  inherit (lib.x) opt;
  inherit (lib.modules) mkIf;
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      cfg = config.services.git-sync;
    in
    {
      options.services.git-sync = {
        enable = opt.bool false;
        package =
          opt.pkg
          <| pkgs.writeNuApplication {
            name = "git-sync";
            runtimeInputs = with pkgs; [
              git
              openssh
            ];
            source = ./git-sync.nu;
          };
        interval = opt.line "*-*-* 23:20:00"; # Runs every day at 11:20 PM
        settings = opt.recursive {
          sync =
            let
              makeRepo = name: {
                inherit name;
                input = "git@github.com:Nadim147c/${name}.git";
                output = {
                  codeberg = "ssh://git@codeberg.org/Nadim147c/${name}.git";
                  gitlab = "git@gitlab.com:Nadim147c/${name}.git";
                };
              };
            in
            [
              (makeRepo "nixos")
              (makeRepo "waybar-lyric")
              (makeRepo "rong")
              (makeRepo "material")
            ];
        };
      };

      config = mkIf cfg.enable {
        home.systemd = {
          timers.git-sync = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = cfg.interval;
              Persistent = true; # Runs missed executions if system was off
              Unit = "git-sync.service";
            };
          };

          services.git-sync = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${getExe cfg.package} ${pkgs.writers.writeJSON "git-sync.json" cfg.settings}";
            };
          };
        };

      };
    };
}
