{ inputs, lib, ... }:
let
  inherit (lib.x) singleton;
  inherit (lib) makeBinPath;
  name = "mpvpaper-daemon";
in
{
  scripts."${name}" = rec {
    inherit name;
    script =
      pkgs:
      inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.writers.writeGoBin name (builtins.readFile ./mpvpaper-daemon.go);
        prefixVar = singleton [
          "PATH"
          ":"
          (makeBinPath [ pkgs.mpvpaper ])
        ];
      };
  };
}
