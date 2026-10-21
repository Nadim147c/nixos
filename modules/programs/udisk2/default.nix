{
  flake.tree.nixos.gui.udisks2 = {
    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };
}
