{
  flake.tree.nixos.base.common = {
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
