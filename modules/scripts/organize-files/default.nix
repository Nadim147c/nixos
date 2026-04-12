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
        runtimeInputs = with pkgs; [
          fd
          self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-base-dir
          magika-cli
          uutils-coreutils-noprefix
        ];
        inheritPath = false;
        source = ./organize-files.nu;
      };
  };
}
