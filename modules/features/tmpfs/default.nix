{
  flake.tree.nixos.base.tmp = {
    boot.tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    systemd.services.nix-daemon = {
      environment.TMPDIR = "/var/tmp";
    };
  };
}
