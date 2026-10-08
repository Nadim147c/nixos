let
  inherit (builtins) attrValues;
in
{
  flake.modules.nixos.gui = { pkgs, ... }: {
    packages = attrValues {
      inherit (pkgs) picard lrcget;
    };
  };
}
