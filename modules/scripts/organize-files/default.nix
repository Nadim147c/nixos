{ self, ... }:
let
  name = "organize-files";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      completion.positionalany = [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = builtins.attrValues {
          inherit (pkgs) fd magika-cli coreutils;
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) xdg-base-dir;
        };
        inheritPath = false;
        source = ./organize-files.nu;
      };
  };
}
