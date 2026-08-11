{ self, lib, ... }:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.strings) escapeShellArg;
  inherit (builtins) attrValues;
  appId = "com.temidaradev.kopuz";
  sha256 = "sha256-fioHNFJJnUsHjG7RIKaqajc10WGynfmfDxfnkX3Mz4A=";
  url = "https://github.com/Kopuz-org/kopuz/releases/download/v0.12.0/kopuz.flatpak";
in
{
  perSystem = { pkgs, ... }: {
    packages.kopuz = pkgs.writeShellScriptBin "kopuz" /* bash */ ''
      exec -a "kopuz" flatpak run -- ${escapeShellArg appId} "$@"
    '';
    packages.fix-kopuz-artists =
      let
        query = escapeShellArg /* sql */ ''
          UPDATE tracks
          SET artist = json_extract(artists_json, '$[0]')
          WHERE artists_json IS NOT NULL
            AND json_valid(artists_json);
        '';
      in
      pkgs.writeShellScriptBin "fix-kopuz-artists" /* bash */ ''
        ${getExe pkgs.sqlite} ~/.config/kopuz/kopuz.db ${query}
      '';
  };

  flake.modules.nixos.gui = { pkgs, system, ... }: {
    # app doesn't work without cache
    preserveHome.directories = [
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
      inherit (pkgs) picard lrcget;
      inherit (self.packages.${system}) kopuz;
    };
  };
}
