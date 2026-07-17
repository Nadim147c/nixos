{ self, ... }:
let
  inherit (builtins) attrValues;
in
{
  flake.modules.nixos.gui = { pkgs, system, ... }: {
    # stupid app doesn't work without cache
    preserveHome.directories = map (p: ".${p}/kopuz") [
      "config"
      "local/share"
    ];

    packages = attrValues {
      inherit (pkgs) picard nicotine-plus lrcget;
      inherit (self.packages.${system}) kopuz;
    };
  };
}
