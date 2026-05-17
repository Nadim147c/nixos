{
  self,
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      createEnvFlag = name: {
        data = "\$${name}";
        esc-fn = lib.x.quote;
      };
    in
    {
      packages.aria2 = inputs.wrappers.wrappers.aria2.wrap (_: {
        inherit pkgs;
        package = pkgs.aria2;
        runShell = [
          /* bash */ ''
            export DOWNLOAD_DIR="''${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
            export SESSION_FILE="''${XDG_DATA_HOME:-$HOME/.local/share}/aria2/aria2.session"
            mkdir -p "$DOWNLOAD_DIR"
            mkdir -p "$(dirname "$SESSION_FILE")"
          ''
        ];
        flags = {
          "--dir" = createEnvFlag "DOWNLOAD_DIR";
          "--save-session" = createEnvFlag "SESSION_FILE";
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
      });
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.aria2 ];
    };
}
