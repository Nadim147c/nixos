{ lib, ... }:
let
  inherit (lib) getExe;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.sessionVariables = {
        EDITOR = getExe pkgs.neovim;
      };
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.neovim ];

    };
}
