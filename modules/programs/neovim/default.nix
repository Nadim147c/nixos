{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib) getExe;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.neovim =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = (inputs.import-tree ./_config).imports;
        }).neovim;
    };

  flake.modules.nixos.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) neovim;
    in
    {
      environment.sessionVariables.EDITOR = getExe neovim;
      environment.systemPackages = [ neovim ];
    };

  flake.modules.homeManager.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) neovim;
    in
    {
      home.packages = [ neovim ];
    };
}
