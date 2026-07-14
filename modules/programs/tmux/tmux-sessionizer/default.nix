{ self, ... }:
let
  name = "tmux-sessionizer";
in
{
  scripts."${name}" = rec {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        inheritPath = true;
        runtimeInputs = builtins.attrValues {
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) fzf tmux-list-repos;
        };
        source = ./tmux-sessionizer.nu;
      };
  };
}
