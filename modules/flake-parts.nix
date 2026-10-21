{
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.treefmt-nix.flakeModule
  ];
  options = {
    flake.tree = mkOption {
      type = types.lazyAttrsOf (types.lazyAttrsOf (types.lazyAttrsOf types.deferredModule));
      description = ''
        A 3-level tree of modules published by the flake.
      '';
    };
  };
}
