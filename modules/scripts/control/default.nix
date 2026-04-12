_:
let
  name = "control";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      parsing = "non-interspersed";
      flags = {
        "-c, --cpu=" = "CPU limit";
        "-m, --memory=" = "Memory limit";
      };
      completion = {
        positional = [
          [
            "$executables"
            "$files"
          ]
        ];
        positionalany = [ "$carapace.bridge.CarapaceBin" ];
      };
    };
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./control.go);
  };
}
