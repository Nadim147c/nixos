{ lib, ... }:
let
  inherit (lib.x) singleton;
in
{
  flake.modules.nixos.dev = {
    preserveHome.directories = singleton ".local/share/direnv";
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      loadInNixShell = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
