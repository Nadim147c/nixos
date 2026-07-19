{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) getExe singleton;
in
{
  perSystem = { pkgs, ... }: {
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
      inherit (self.packages.${system}) carapace;
      init = "${getExe carapace} init";
    in
    {
      packages = singleton carapace;
      # The sed expression removes the unncessary add of
      # XDG_CONFIG_HOME/carapace/bin to path
      programs = {
        bash.init.carapace = ''
          ${init} bash | sed '/\/homeless-shelter/d'
        '';

        zsh.init.carapace = ''
          ${init} zsh | sed '/\/homeless-shelter/d'
        '';

        fish.init.carapace = ''
          ${init} fish | sed '/\/homeless-shelter/d'
        '';

        nushell.init.carapace = ''
          ${init} nushell | sed '/\/homeless-shelter/d'
        '';
      };
    };
}
