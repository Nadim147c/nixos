{
  flake.modules.nixos.base = {
    documentation.man = {
      enable = true;
      man-db.enable = true;
      cache.enable = false;
    };
  };

  flake.modules.homeManager.base = {
    manual.manpages.enable = true;
    programs.man = {
      enable = true;
      generateCaches = false;
    };
  };
}
