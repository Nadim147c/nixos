{ self, ... }:
let
  name = "tmux-sessionizer";
in
{
  scripts."${name}" = rec {
    inherit name;
    script =
      pkgs:
      let
        inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) fzf tmux-list-repos;
      in
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = [
          fzf
          tmux-list-repos
        ];
        source = ./tmux-sessionizer.nu;
      };
  };
}
