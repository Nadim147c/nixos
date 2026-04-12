_:
let
  name = "git-copy";
in
{
  scripts."${name}" = {
    inherit name;
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./git-copy.go);
  };
}
