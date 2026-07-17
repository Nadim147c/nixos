{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) toList;
in
{
  perSystem = { pkgs, ... }: {
    packages.cava = inputs.wrappers.wrappers.cava.wrap {
      inherit pkgs;
      package = pkgs.cava;
      settings = {
        color.theme = "rong";
      };
    };
  };

  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      programs.rong.settings.themes = toList {
        target = "cava.ini";
        links = "${config.home.xdg.config.directory}/cava/themes/rong";
        cmds = pkgs.writers.writeNu "reload-cava" /* nu */ ''
          let pids = ps | find cava | get pid
          if ($pids | is-not-empty) {
            kill -s 12 ...$pids
          }
        '';
      };

      packages = [ self.packages.${system}.cava ];
    };
}
