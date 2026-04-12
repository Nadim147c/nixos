{ ... }:
{
  flake.modules.homeManager.base = args: {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyFile = "${args.config.xdg.dataHome}/bash/history";
    };
  };
}
