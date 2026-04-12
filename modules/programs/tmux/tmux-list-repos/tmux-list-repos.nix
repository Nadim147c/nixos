let
  name = "tmux-list-repos";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-d, --max-depth=" = "Maximum directory recursion depth";
      };
      completion = {
        positional = [ [ "$files" ] ];
      };
    };
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./tmux-list-repos.go);
  };
}
