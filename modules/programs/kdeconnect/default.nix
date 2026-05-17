{
  flake.modules.nixos.pc = {
    programs.kdeconnect.enable = true;
  };

  flake.modules.homeManager.pc = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
