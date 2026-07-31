{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) singleton;
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
      programs.rong.settings.themes = singleton {
        target = "cava.ini";
        links = "${config.hj.xdg.config.directory}/cava/themes/rong";
        cmds = pkgs.writers.writeNu "reload-cava" /* nu */ ''
          let pids = ps | find cava | get pid
          if ($pids | is-not-empty) {
            kill -s 12 ...$pids
          }
        '';
      };

      packages = singleton self.packages.${system}.cava;
    };
}
