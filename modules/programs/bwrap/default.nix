{
  flake.modules.nixos.base = { pkgs, ... }: {
    security.wrappers.bwrap = {
      source = "${pkgs.bubblewrap}/bin/bwrap";
      owner = "root";
      group = "root";
      setuid = false;
      setgid = false;
    };
  };
}
