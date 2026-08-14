let
  inherit (builtins) attrValues;
in
{
  flake.modules.nixos.gui = { pkgs, ... }: {
    # app doesn't work without cache
    preserveHome.directories = [
      ".config/MusicBrainz"
    ];

    packages = attrValues {
      inherit (pkgs) picard lrcget;
    };
  };
}
