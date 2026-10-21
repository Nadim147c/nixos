{ lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.modules) mkAfter;
  inherit (lib.strings) concatMapAttrsStringSep;
  inherit (lib.x) opt;
in
{
  flake.tree.nixos.base.common =
    { config, pkgs, ... }:
    let
      makeSource = name: value: "source ${pkgs.mkInitScript "init-${name}.bash" value}";
      extraInit = concatMapAttrsStringSep "\n" makeSource config.programs.bash.init;
    in
    {
      options.programs.bash.init = opt.attrs.block { };
      config.programs.bash.interactiveShellInit = mkAfter extraInit;
    };

  flake.tree.nixos.base.bash = {
    environment.pathsToLink = singleton "/share/bash-completions";
    programs.bash.enable = true;
  };
}
