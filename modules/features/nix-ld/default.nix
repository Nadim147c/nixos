_: {
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          acl
          attr
          bzip2
          curl
          libsodium
          libssh
          libxml2
          libz
          openssl
          stdenv.cc.cc
          stdenv.cc.cc.lib
          systemd
          util-linux
          xz
          zlib
          zstd
        ];
      };
    };

}
