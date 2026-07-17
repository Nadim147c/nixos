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
    };
}
