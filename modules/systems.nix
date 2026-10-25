{
  self,
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mapAttrs escapeNixIdentifier;
in
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.tree.nixos.base.common =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      _module.args.system = pkgs.stdenv.hostPlatform.system;
      # Following snippet is copied from flake-parts
      _module.args.inputs' = mapAttrs (
        inputName: input:
        builtins.addErrorContext "while retrieving system-dependent attributes for input ${escapeNixIdentifier inputName}"
        <| (
          if input._type or null == "flake" then
            config.perInput system input
          else
            throw "Trying to retrieve system-dependent attributes for input ${escapeNixIdentifier inputName}, but this input is not a flake. Perhaps flake = false was added to the input declarations by mistake, or you meant to use a different input, or you meant to use plain old inputs, not inputs'."
        )
      ) inputs;
      _module.args.self' =
        builtins.addErrorContext "while retrieving system-dependent attributes for a flake's own outputs"
        <| config.perInput system self;
    };
}
