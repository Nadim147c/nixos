{ lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
in
{
  flake.tree.nixos.base.zoxide =
    { pkgs, ... }:
    let
      init = "${getExe pkgs.zoxide} init --cmd=cd";
    in
    {
      packages = singleton pkgs.zoxide;
      programs = {
        bash.init.zoxide = ''
          ${init} bash
        '';

        zsh.init.zoxide = ''
          ${init} zsh
        '';

        fish.init.zoxide = ''
          ${init} fish
        '';

        nushell.init.zoxide = ''
          ${init} nushell
        '';
      };
    };
}
