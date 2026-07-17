let
  name = "git-copy";
in
{
  scripts."${name}" = {
    completion = {
      inherit name;
      flags = {
        "-d, --destination=" = "destination to clone the reposition";
      };
      completion.positional = [
        [ "$files" ]
      ];
    };
    inherit name;
    script =
      pkgs:
      let
        args.runtimeInputs = with pkgs; [
          openssh
          gh
          git
          jujutsu
        ];
      in
      pkgs.writers.writeGoBin name args (builtins.readFile ./git-copy.go);
  };
}
