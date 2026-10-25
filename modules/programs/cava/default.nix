{
  self,
  lib,
  ...
}:
let
  inherit (lib) singleton;

in
{
  flake.wrappers.cava = { wlib, ... }: {
    imports = [ wlib.wrapperModules.cava ];
  };

  flake.tree.nixos.gui.cava =
    { config, pkgs, ... }:
    {
      imports = [ self.wrappers.cava.install ];

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

      wrappers.cava = {
        enable = true;
        settings.color.theme = "rong";
      };
    };
}
