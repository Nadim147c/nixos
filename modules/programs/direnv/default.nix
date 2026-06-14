{
  flake.modules.nixos.dev = {
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
