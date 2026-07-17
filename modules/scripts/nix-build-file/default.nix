{ lib, ... }:
let
  inherit (lib.x) singleton;
  name = "nix-build-file";
in
{
  scripts."${name}" = {
    completion = {
      inherit name;
      completion.positional = singleton [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        inheritPath = true;
        source = ./nix-build-file.nu;
      };
  };
}
