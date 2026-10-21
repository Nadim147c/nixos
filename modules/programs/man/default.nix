{
  flake.tree.nixos.base.man = {
    documentation.man = {
      enable = true;
      man-db.enable = true;
      cache.enable = true;
    };
  };
}
