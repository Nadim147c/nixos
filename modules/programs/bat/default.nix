{
  flake.modules.nixos.base =
    { pkgs, lib, ... }:
    let
      inherit (lib) getExe;
    in
    {
      environment.shellAliases.cat = getExe pkgs.bat;
      packages = [
        pkgs.bat
        pkgs.bat-extras.batman
      ];
    };
}
