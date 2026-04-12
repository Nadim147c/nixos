{ lib, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.shellAliases.man = "${lib.getExe' pkgs.bat-extras.batman "batman"}";
      programs.bat = {
        enable = true;
        config = {
          pager = "${pkgs.less}/bin/less -rF";
          theme = "ansi";
        };
      };
    };
}
