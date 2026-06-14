{
  flake.modules.nixos.base = {
    documentation.man = {
      enable = true;
      man-db.enable = true;
      cache.enable = true;
    };
  };
}
