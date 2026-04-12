{ inputs, ... }:
{

  configurations.nixos.chronoshift.module =
    { modulesPath, ... }:
    {

      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        "${inputs.nixos-hardware}/common/cpu/intel/skylake"
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
      boot.kernelParams = [
        "quiet"
        "splash"

        "boot.shell_on_fail"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      fileSystems."/" = {
        device = "/dev/mapper/luks-275904fa-0ec3-46b6-b623-1b431bbc8b73";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

      boot.initrd.luks.devices."luks-275904fa-0ec3-46b6-b623-1b431bbc8b73" = {
        device = "/dev/disk/by-uuid/275904fa-0ec3-46b6-b623-1b431bbc8b73";
      };
      boot.initrd.luks.devices."luks-e1ed6ba6-39c3-4dc1-a582-931643469112" = {
        device = "/dev/disk/by-uuid/e1ed6ba6-39c3-4dc1-a582-931643469112";
      };

      fileSystems."/home" = {
        device = "/dev/mapper/luks-275904fa-0ec3-46b6-b623-1b431bbc8b73";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/DD36-87A0";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ { device = "/dev/mapper/luks-e1ed6ba6-39c3-4dc1-a582-931643469112"; } ];
    };
}
