{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.wget = inputs.wrappers.lib.wrapPackage (
        { config, ... }:
        {
          inherit pkgs;
          package = pkgs.wget;
          runShell = [
            /* bash */ ''
              if [[ -z "$WGETRC" ]]; then
                tmp=$(mktemp)
                echo "hsts-file = ''${XDG_CACHE_HOME:-$HOME/.cache}/wget-hsts" > "$tmp"
                export WGETRC="$tmp"
                cleanup() {
                  rm -f "$tmp"
                }
                trap cleanup EXIT
              fi
            ''
          ];
        }
      );
    };

  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.wget ];
      home.sessionVariables.WGETRC = pkgs.writeText "wgetrc" ''
        hsts-file = ${config.xdg.cacheHome}/wget-hsts
      '';
    };
}
