{
  flake.modules.nixos.wireless = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
    services.blueman.enable = true;
  };

  flake.modules.homeManager.wireless = {
    services.blueman-applet.enable = false;
  };
}
