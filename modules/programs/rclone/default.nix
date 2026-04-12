{ ... }:
{
  flake.modules.nixos.base = {
    programs.fuse = {
      enable = true;
      userAllowOther = true;
    };
  };

  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      rcloneConfigDir = "${config.xdg.configHome}/rclone";
    in
    {
      # Currently rclone-config.service overrides dynamically
      # acquired tokens. This service will backup the token
      # and restore it after the rebuild.
      # See: https://github.com/nix-community/home-manager/issues/8334
      systemd.user.services.rclone-config-post-edit = {
        Unit = {
          Description = "Post-process rclone configuration at ${rcloneConfigDir}";
          After = [ "rclone-config.service" ];
          Requires = [ "rclone-config.service" ];
        };

        Service = {
          Type = "oneshot";
          # RemainAfterExit is often useful for oneshots that "setup" a state
          RemainAfterExit = false;
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "rclone-config-post-edit";
              runtimeInputs = with pkgs; [
                coreutils
                rclone
                jq
              ];
              text = ''
                TIMESTAMP=$(date +%s)
                BACKUP="${rcloneConfigDir}/.rclone.conf.orig"
                MASTER="${rcloneConfigDir}/rclone.conf"

                # Create a permanent backup!
                cp "$BACKUP" "${rcloneConfigDir}/.$TIMESTAMP.rclone.conf.bak"

                GDRIVE_TOKEN=$(rclone config dump --config "$BACKUP" | jq -Mrc .gdrive.token)
                if [[ "$GDRIVE_TOKEN" != "null" ]]; then
                  echo "Updating rclone config with gdrive token."
                  rclone config update \
                    --config "$MASTER" \
                    --non-interactive \
                    gdrive token "$GDRIVE_TOKEN"
                fi
              '';
            }
          );
        };
        Install.WantedBy = [ "default.target" ];
      };

      programs.rclone = {
        enable = true;
        requiresUnit = null;
        remotes = {
          # BACKEND
          gdrive = {
            config = {
              type = "drive";
              scope = "drive";
              config_is_local = true;
              disable_http2 = true;
            };

            secrets = {
              client_id = config.sops.secrets."rclone/gdrive/id".path;
              client_secret = config.sops.secrets."rclone/gdrive/secret".path;
            };
          };

          # ENCRYPTED VIEW
          gdrive-enc = {
            config = {
              type = "crypt";
              remote = "gdrive:encrypted"; # folder on Drive where encrypted data lives
              filename_encryption = "standard";
              directory_name_encryption = true;
            };

            secrets = {
              password = config.sops.secrets."rclone/crypt/pass".path;
              password2 = config.sops.secrets."rclone/crypt/salt".path;
            };

            mounts."gdrive" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/gdrive";
              options = {
                allow-non-empty = true;
                allow-other = true;
                buffer-size = "256M";
                cache-dir = "${config.xdg.cacheHome}/rclone";
                vfs-cache-mode = "full";
                vfs-read-chunk-size = "128M";
                vfs-read-chunk-size-limit = "1G";
                dir-cache-time = "5000h";
                poll-interval = "15s";
                vfs-cache-max-age = "1h";
                vfs-cache-max-size = "1G";
                umask = "000";
                gid = "100";
              };
            };
          };
        };
      };
    };
}
