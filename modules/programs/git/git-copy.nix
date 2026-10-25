let
  name = "git-copy";
in
{
  scripts."${name}" = {
    completion = {
      inherit name;
      flags = {
        "-d, --destination=" = "Destination directory (default: ~/git/<user>/<repo>)";
        "-g, --git" = "Use `git clone --recursive` instead of `jj git clone`";
      };
      completion.positional = [
        [ "$files" ]
      ];
    };
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          openssh
          gh
          git
          jujutsu
        ];
        source = ./git-copy.nu;
      };
  };
}
