{
  inputs,
  config,
  ...
}:
let
  inherit (config.flake.modules) nixos;
in
{

  perSystem = { pkgs, ... }: {
    packages.steam = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [ pkgs.mangohud ];
      };
      envDefault."MANGOHUD" = "1";
    };
  };
  flake.modules.nixos.game = {
    imports = [ nixos.steam ];
  };
  flake.modules.nixos.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      extraPackages = with pkgs; [
        mangohud
      ];
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
        };
      };
    };
  };
}
