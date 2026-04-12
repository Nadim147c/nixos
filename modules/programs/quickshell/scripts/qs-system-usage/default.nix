let
  name = "qs-system-usage";
in
{
  scripts."${name}" = rec {
    inherit name;
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./system-usage.go);
  };
}
