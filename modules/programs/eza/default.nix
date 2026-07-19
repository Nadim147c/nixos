{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) singleton getExe;
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
      inherit (self.packages.${system}) eza;
      bin = getExe eza;
    in
    {
      packages = singleton eza;
      environment.shellAliases = {
        l = "${bin} -alh";
        ls = bin;
        ll = "${bin} -l";
        la = "${bin} -a";
        lt = "${bin} --tree";
      };
    };
}
