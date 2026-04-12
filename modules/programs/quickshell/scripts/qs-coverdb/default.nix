{ self, ... }:
let
  name = "qs-coverdb";
in
{
  scripts."${name}" = rec {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = [ self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-base-dir ];
        source = ./qs-coverdb.nu;
      };
  };
}
