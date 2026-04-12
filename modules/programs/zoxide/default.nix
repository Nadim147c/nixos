_: {
  flake.modules.homeManager.base = {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      options = [ "--cmd=cd" ];
    };
  };
}
