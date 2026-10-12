{ self, lib, ... }:
let
  inherit (lib.meta) getExe;
  name = "qs-run-terminal";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeShellScriptBin name ''
        PATH=/run/current-system/sw/bin:$PATH ${
          getExe self.packages.${pkgs.stdenv.hostPlatform.system}.kitty
        } --directory="''$(${
          getExe self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-base-dir
        } user-downloads)" "$@"
      '';
  };
}
