/**
  Rclone saves dynamically generated OAuth2 tokens in the same place as
  static tokens like client_id and client_secret. So OAuth2 tokens
  get overwritten on NixOS switch.
  I could make some crazy hack to replace statically supplied static
  tokens from sops-nix. But it's far easier to edit the config
  once manually.

  ```bash
    sops ./secrets/secrets.yaml
  ```

  ```bash
    mkdir -p ~/.config/rclone
    nvim ~/.config/rclone/rclone.conf
  ```

  ```ini
    [gdrive]
    config_is_local = true
    disable_http2 = true
    scope = drive
    type = drive
    client_id = REPLACE_ME
    client_secret = REPLACE_ME

    [gdrive-enc]
    directory_name_encryption = true
    filename_encryption = standard
    remote = gdrive:encrypted
    type = crypt
    password = REPLACE_ME
    password2 = REPLACE_ME
  ```

  Now Generate OAuth2 token by logging in:

  ```bash
    rclone config edit
  ```
*/

{ lib, ... }:
let
  inherit (lib)
    singleton
    getExe'
    mapAttrsToList
    optionalString
    escapeShellArgs
    escapeShellArg
    ;
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      makeFlag =
        name: value:
        if builtins.isBool value then
          "--${optionalString (!value) "no-"}${name}"
        else if builtins.isString value then
          "--${name}=${value}"
        else
          throw "unsupported flag value";

      mountOptions = {
        allow-non-empty = true;
        allow-other = true;
        buffer-size = "256M";
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

      mountFlags = mapAttrsToList makeFlag mountOptions |> escapeShellArgs;
      mountPath = escapeShellArg "${config.home.directory}/gdrive";
    in
    {
      programs.fuse = {
        enable = true;
        userAllowOther = true;
      };

      packages = singleton pkgs.rclone;
      home.systemd.services.rclone = {
        enable = true;
        description = "rclone gdrive FUSE mount";
        wantedBy = singleton "default.target";
        serviceConfig = {
          # fusermount/fusermount3
          Environment = singleton "PATH=/run/wrappers/bin";
          ExecStartPre = "${getExe' pkgs.coreutils "mkdir"} -p ${mountPath}";
          ExecStart = pkgs.writeShellScript "rclone-mount" ''
            ${getExe' pkgs.rclone "rclone"} mount ${mountFlags} gdrive-enc:gdrive ${mountPath}
          '';
          SuccessExitStatus = "143";
        };
      };
    };
}
