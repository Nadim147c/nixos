{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) toList getExe;
in
{

  perSystem =
    { pkgs, ... }:
    {
      packages.eza = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.eza;
        flags = {
          "--icons" = "auto";
          "--color" = "auto";
        };
        flagSeparator = "=";
      };
    };

  flake.modules.nixos.base =
    { system, ... }:
    let
      bin = getExe self.packages.${system}.eza;
    in
    {
      packages = toList self.packages.${system}.eza;
      environment.shellAliases = {
        l = "${bin} -alh";
        ls = "${bin}";
        ll = "${bin} -l";
        la = "${bin} -a";
        lt = "${bin} --tree";
      };
    };
}
