{ self, inputs, ... }:
{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      programs.atuin = {
        enable = true;
        daemon.enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          db_path = "${config.xdg.dataHome}/atuin/history.db";
          inline_height = 20;
          invert = true;
          style = "compact";
        };
      };
    };
}
