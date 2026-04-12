{ ... }:
{
  flake.modules.nixos.base = {
    programs.nh.enable = true;
  };

  flake.modules.homeManager.base = {
    programs.nh.enable = true;
  };
}
