{ self, lib, ... }:
let
  inherit (lib) escapeShellArg singleton;
  inherit (builtins) attrValues;
  appId = "com.temidaradev.kopuz";
  sha256 = "sha256-EvUZ5j8kXQP62DT1opY4mu3Ev2reXTcGPy9fUAbFKyE=";
  url = "https://github.com/Kopuz-org/kopuz/releases/download/v0.11.0/kopuz.flatpak";
in
{
  perSystem = { pkgs, ... }: {
    packages.kopuz = pkgs.writeShellScriptBin "kopuz" /* bash */ ''
      exec -a "kopuz" flatpak run -- ${escapeShellArg appId} "$@"
    '';
  };

  flake.modules.nixos.gui = { pkgs, system, ... }: {
    # app doesn't work without cache
    preserveHome.directories = [
      ".config/nicotine"
      ".config/MusicBrainz"
      ".config/kopuz"
      ".cache/kopuz"
      ".local/share/kopuz"
    ];

    services.flatpak = {
      packages = singleton {
        inherit sha256 appId;
        bundle = toString <| pkgs.fetchurl { inherit sha256 url; };
      };
      overrides.settings."${appId}" = {
        Context.filesystems = [
          "xdg-config/kopuz"
          "xdg-music"
        ];
      };
    };

    packages = attrValues {
      inherit (pkgs) picard nicotine-plus lrcget;
      inherit (self.packages.${system}) kopuz;
    };
  };
}
