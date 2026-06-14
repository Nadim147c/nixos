{
  flake.modules.nixos.base = {
    boot.tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    systemd.services.nix-daemon = {
      environment.TMPDIR = "/var/tmp";
    };
  };
}
