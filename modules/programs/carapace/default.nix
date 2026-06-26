{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) getExe toList;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.carapace = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.carapace;
        envDefault = {
          CARAPACE_BRIDGES = "carapace,zsh,fish,bash";
          CARAPACE_MATCH = "1";
        };
      };
    };

  flake.modules.nixos.base =
    { system, ... }:
    let
      bin = getExe self.packages.${system}.carapace;
    in
    {
      packages = toList self.packages.${system}.carapace;
      # The sed expression removes the unncessary add of
      # XDG_CONFIG_HOME/carapace/bin to path
      programs = {
        bash.init.carapace = ''
          ${bin} _carapace bash | sed '/\/homeless-shelter/d'
        '';

        zsh.init.carapace = ''
          ${bin} _carapace zsh | sed '/\/homeless-shelter/d'
        '';

        fish.init.carapace = ''
          ${bin} _carapace fish | sed '/\/homeless-shelter/d'
        '';

        nushell.init.carapace = ''
          ${bin} _carapace nushell | sed '/\/homeless-shelter/d'
        '';
      };
    };
}
