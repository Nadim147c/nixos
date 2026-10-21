{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) singleton;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.wget = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.wget;
        runShell = singleton /* bash */ ''
          if [[ -z "$WGETRC" ]]; then
            tmp=$(mktemp)
            echo "hsts-file = ''${XDG_CACHE_HOME:-$HOME/.cache}/wget-hsts" > "$tmp"
            export WGETRC="$tmp"
            cleanup() {
              rm -f "$tmp"
            }
            trap cleanup EXIT
          fi
        '';
      };
    };

  flake.tree.nixos.base.wget =
    {
      config,
      system,
      pkgs,
      ...
    }:
    {
      packages = singleton self.packages.${system}.wget;
      sessionVariables.WGETRC = pkgs.writeText "wgetrc" /* ini */ ''
        hsts-file = ${config.hj.xdg.cache.directory}/wget-hsts
      '';
    };
}
