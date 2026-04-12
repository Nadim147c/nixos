{ ... }:
{
  flake.modules.homeManager.dev = {
    programs.direnv = {
      enable = true;
      silent = true;
      mise.enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      # enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
