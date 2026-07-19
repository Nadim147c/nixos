{ lib, ... }:
let
  inherit (lib) singleton;
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
        "-s, --scope" = "Run in terminal scope";
      };
      completion = {
        positional = singleton [ "$executables" ];
        positionalany = singleton "$carapace.bridge.CarapaceBin";
      };
    };
    script =
      pkgs:
      let
        args = {
          inheritPath = true;
          runtimeInputs = [ pkgs.uwsm ];
        };
      in
      pkgs.writers.writeGoBin name args (builtins.readFile ./control.go);
  };
}
