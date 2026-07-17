{
  flake.modules.nixos.base = {
    documentation.man = {
      enable = true;
      man-db.enable = false;
      cache.enable = false;
    };
  };
}
