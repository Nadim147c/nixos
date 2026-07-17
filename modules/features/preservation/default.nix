{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config) username;
  inherit (lib) const genAttrs;
in
{
  flake.modules.nixos.base = {
    imports = [ inputs.preservation.nixosModules.default ];

    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        directories = [
          "/etc/nixos"
          "/etc/secureboot"
          "/var/lib/flatpak"
          "/var/lib/bluetooth"
          "/var/lib/fprint"
          "/var/lib/fwupd"
          "/var/lib/libvirt"
          "/var/lib/power-profiles-daemon"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/systemd/timers"
          "/var/log"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];

        files = [
          "/var/sops/age.txt"
          {
            file = "/etc/machine-id";
            inInitrd = true;
            how = "symlink";
            configureParent = true;
          }
        ];

        users.${username} = {
          # This dicistion was not made lightly!!!! Some application just
          # doesn't work well without persitence cache!
          directories = [
            ".cache"
            ".local/bin"
          ];
        };
      };
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [
        ""
        "/persistent/etc/machine-id"
      ];
      serviceConfig.ExecStart = [
        ""
        "systemd-machine-id-setup --commit --root /persistent"
      ];
    };

    systemd.tmpfiles.settings.preservation =
      let
        mode.d = {
          user = config.username;
          group = "users";
          mode = "0755";
        };
      in
      genAttrs [
        "/home/${username}/.config"
        "/home/${username}/.local"
        "/home/${username}/.local/share"
        "/home/${username}/.local/state"
      ] (const mode);
  };
}
