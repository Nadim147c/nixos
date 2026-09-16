{ self, ... }:
let
  name = "qs-coverdb";
in
{
  scripts."${name}" = rec {
    inherit name;
    script =
      pkgs:
      let
        qs-stylize-cover = pkgs.writers.writeGoBin "qs-stylize-cover" (
          builtins.readFile ./qs-stylize-cover.go
        );
      in
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-base-dir
          qs-stylize-cover
        ];
        source = ./qs-coverdb.nu;
      };
  };
}
