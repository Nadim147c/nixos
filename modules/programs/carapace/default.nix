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
    { pkgs, system, ... }:
    let
      bin = getExe self.packages.${system}.carapace;
      nushellSource = pkgs.runCommand "carapace.nu" { } ''
        ${bin} _carapace nushell | sed 's|"/homeless-shelter|$"($env.HOME)|g' > "$out"
      '';
    in
    {
      packages = toList self.packages.${system}.carapace;
      programs = {
        bash.interactiveShellInit = ''
          source <(${bin} _carapace bash)
        '';

        zsh.interactiveShellInit = ''
          source <(${bin} _carapace zsh)
        '';

        fish.interactiveShellInit = ''
          ${bin} _carapace fish | source
        '';

        nushell.interactiveShellInit = ''
          source ${nushellSource}
        '';
      };
    };
}
