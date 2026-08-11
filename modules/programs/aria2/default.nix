{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.x) makeEnvFlag;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      xdg-base-dir = getExe self'.packages.xdg-base-dir;
    in
    {
      packages.aria2 = inputs.wrappers.wrappers.aria2.wrap {
        inherit pkgs;
        package = pkgs.aria2;
        runShell = singleton /* bash */ ''
          export download_dir=$(${xdg-base-dir} user-download)
          export session_file="$(${xdg-base-dir} state-home)/aria2/aria2.session"
          mkdir -p "$download_dir"
          mkdir -p "$(dirname "$session_file")"
        '';
        flags = {
          "--dir" = makeEnvFlag "download_dir";
          "--save-session" = makeEnvFlag "session_file";
        };
        settings = {
          allow-overwrite = true;
          allow-piece-length-change = true;
          always-resume = true;
          async-dns = false;
          auto-file-renaming = true;
          content-disposition-default-utf8 = true;
          continue = true;
          disk-cache = "64M";
          enable-rpc = false;
          file-allocation = "falloc";
          max-concurrent-downloads = 5;
          max-connection-per-server = 5;
          max-download-limit = 0;
          max-overall-download-limit = 0;
          min-split-size = "10M";
          no-file-allocation-limit = "8M";
          save-session-interval = 60;
          split = 10;
        };
      };
    };

  flake.modules.nixos.base = { system, ... }: {
    packages = singleton self.packages.${system}.aria2;
  };
}
