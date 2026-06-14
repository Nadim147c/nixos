{
  flake.modules.nixos.base = {
    boot = {
      loader.systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max";
      };
      loader.efi.canTouchEfiVariables = true;
      initrd.systemd.enable = true;
      initrd.verbose = false;
      consoleLogLevel = 0;
    };
  };
}
