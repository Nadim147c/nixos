{ lib, ... }:
let
  inherit (lib) toList getExe;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    let
      init = "${getExe pkgs.zoxide} init --cmd=cd";
    in
    {
      packages = toList pkgs.zoxide;
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
