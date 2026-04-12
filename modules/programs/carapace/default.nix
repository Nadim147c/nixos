{ ... }:
{

  flake.modules.homeManager.base = {
    home.sessionVariables = {
      CARAPACE_BRIDGES = "carapace,zsh,fish,bash";
      CARAPACE_MATCH = "1";
    };
    programs.carapace = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
