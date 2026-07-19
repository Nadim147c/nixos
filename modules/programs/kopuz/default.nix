{ self, ... }:
let
  inherit (builtins) attrValues;
in
{
  flake.modules.nixos.gui = { pkgs, system, ... }: {
    # app doesn't work without cache
    preserveHome.directories = [
      ".config/kopuz"
      ".cache/kopuz"
      ".local/share/kopuz"
    ];

    packages = attrValues {
      inherit (pkgs) picard nicotine-plus lrcget;
      inherit (self.packages.${system}) kopuz;
    };
  };
}
