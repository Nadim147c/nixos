_: {
  flake.modules.nixos.pc = {
    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };
}
