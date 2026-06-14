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
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./git-copy.go);
  };
}
