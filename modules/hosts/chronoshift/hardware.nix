{ inputs, lib, ... }:
{

  configurations.nixos.chronoshift.module =
    { modulesPath, config, ... }:
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
        device = "/dev/disk/by-uuid/3217db6e-676c-4ffe-8d34-5f3c21cd8cf8";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/DA50-BF87";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/c6b2c67a-e8df-4f76-a89b-8add67e8fab3"; }
      ];

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
