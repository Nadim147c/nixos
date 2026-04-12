{ ... }:
{
  flake.modules.homeManager.base = {
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = false;
      enableZshIntegration = true;
      icons = "auto";
    };
  };
}
