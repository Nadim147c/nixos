{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.treefmt-nix.flakeModule
  ];
}
