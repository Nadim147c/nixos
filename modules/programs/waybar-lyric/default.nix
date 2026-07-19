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
  perSystem = { pkgs, ... }: {
    packages.waybar-lyric-impure = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.waybar-lyric;
      runShell = singleton /* bash */ ''
        override="$HOME/.local/bin/waybar-lyric"
        if [[ -x "$override" ]]; then
          exec -a "$0" "$override" "$@"
          exit
        fi
      '';
    };
  };

  flake.modules.nixos.gui = { system, ... }: {
    packages = singleton self.packages.${system}.waybar-lyric-impure;
  };
}
