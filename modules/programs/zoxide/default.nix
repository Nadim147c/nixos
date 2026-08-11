{ lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    let
      init = "${getExe pkgs.zoxide} init --cmd=cd";
    in
    {
      preserveHome.directories = singleton ".local/share/zoxide";
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
