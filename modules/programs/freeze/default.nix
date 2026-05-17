{ self, inputs, ... }:
{

  perSystem =
    { pkgs, ... }:
    {
      packages.freeze = inputs.wrappers.lib.wrapPackage (_: {
        inherit pkgs;
        package = pkgs.charm-freeze;
        runShell = [
          /* bash */ ''
            DOWNLOAD_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}/freeze"
            mkdir -p "$DOWNLOAD_DIR"
            DOWNLOAD_FILE="''${DOWNLOAD_DIR}/$(date +'%Y-%m-%d_%H-%M-%S').png"
          ''
        ];
        flags."--output" = {
          data = "$DOWNLOAD_FILE";
          esc-fn = x: "\"${x}\"";
        };
        flagSeparator = "=";
      });
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.freeze ];
    };
}
