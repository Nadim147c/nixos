{ lib, ... }:
let
  inherit (lib) singleton mkAfter concatMapAttrsStringSep;
  inherit (lib.x) opt;
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      makeSource = name: value: "source ${pkgs.mkInitScript "init-${name}.bash" value}";
      extraInit = concatMapAttrsStringSep "\n" makeSource config.programs.bash.init;
    in
    {
      options.programs.bash.init = opt.attrs.block { };

      config = {
        preserveHome.directories = singleton ".local/share/bash-completions";
        environment.pathsToLink = singleton "/share/bash-completions";
        programs.bash = {
          enable = true;
          interactiveShellInit = mkAfter extraInit;
        };
      };
    };
}
