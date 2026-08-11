{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs mapAttrsToList;
  inherit (lib.modules) mkMerge;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) flip;
in
{
  options.configurations.nixos = mkOption {
    type = types.attrsOf (
      types.submodule {
        options.module = mkOption {
          type = types.deferredModule;
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations =
      flip mapAttrs config.configurations.nixos
      <| (name: { module }: inputs.nixpkgs.lib.nixosSystem { modules = [ module ]; });

    checks =
      let
        makeChecks = name: nixos: {
          "${nixos.config.nixpkgs.hostPlatform.system}" = {
            "configurations/nixos/${name}" = nixos.config.system.build.toplevel;
          };
        };
      in
      config.flake.nixosConfigurations |> mapAttrsToList makeChecks |> mkMerge;
  };
}
