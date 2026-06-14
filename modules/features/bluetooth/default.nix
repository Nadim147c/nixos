{
  flake.modules.nixos.wireless = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
    services.blueman.enable = true;
  };

  flake.modules.nixos.gui =
    { pkgs, lib, ... }:
    let
      inherit (lib) toList getExe';
    in
    {
      home.systemd.services.blueman-applet = rec {
        enable = true;
        description = "Blueman applet";
        requires = toList "tray.target";
        partOf = toList "graphical-session.target";
        after = [
          "graphical-session.target"
          "tray.target"
        ];
        wantedBy = partOf;
        serviceConfig = {
          ExecStart = getExe' pkgs.blueman "blueman-applet";
        };
      };
    };
}
