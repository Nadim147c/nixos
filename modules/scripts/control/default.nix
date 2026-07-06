{ inputs, lib, ... }:
let
  inherit (lib) makeBinPath;
  inherit (lib.x) singleton;
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
        positional = [
          [
            "$executables"
            "$files"
          ]
        ];
        positionalany = [ "$carapace.bridge.CarapaceBin" ];
      };
    };
    script =
      pkgs:
      inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.writers.writeGoBin name (builtins.readFile ./control.go);
        prefixVar = singleton [
          "PATH"
          ":"
          (makeBinPath [ pkgs.uwsm ])
        ];
      };
  };
}
