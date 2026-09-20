{ lib, inputs, ... }:
let
  inherit (lib) getName;
  isDefaultNix = p: (builtins.match ".*/default\\.nix$" p) != null;
  overlays =
    lib.filesystem.listFilesRecursive ../overlays
    |> map toString
    |> builtins.filter isDefaultNix
    |> map (x: (import x) inputs);
  config.allowUnfreePredicate =
    pkg:
    builtins.elem (getName pkg) [
      "discord"
      "discord-unwrapped"
      "steam"
      "steam-unwrapped"
    ];

in
{
  perSystem =
    { pkgs, system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system overlays config;
      };

      # Recusivinly find all default.nix files in ../pkgs and sets {
      #  parent-name = pkgs.callPackage <path> {};
      # };
      packages =
        let
          createPackage = p: lib.nameValuePair (dirOf p |> baseNameOf) (pkgs.callPackage p { });
        in
        toString ../pkgs
        |> lib.filesystem.listFilesRecursive
        |> builtins.filter isDefaultNix
        |> map createPackage
        |> builtins.listToAttrs;
    };

  flake.modules.nixos.base = {
    nixpkgs = { inherit overlays config; };
  };
}
