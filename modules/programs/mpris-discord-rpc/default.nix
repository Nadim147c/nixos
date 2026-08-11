{ self, lib, ... }:
let
  inherit (lib.fixedPoints) fix;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.strings) escapeShellArg;

  settings = {
    ignore = [
      "kdeconnect.*"
      ".*chromium.*"
    ];
    priority = [
      "kopuz"
    ];
    required_metadata = [
      "xesam:title"
      "xesam:album"
      "xesam:artist"
    ];
  };
in
{
  flake.modules.nixos.gui =
    {
      pkgs,
      config,
      system,
      ...
    }:
    {
      preserveHome.directories = singleton ".local/share/mpris-discord-rpc";

      hj.systemd.services.mpris-discord-rpc = fix (final: {
        enable = false;
        description = "MPRIS Proxy to Discord Rice Presence";
        partOf = singleton "graphical-session.target";
        after = final.partOf;
        wantedBy = final.partOf;
        reloadTriggers = with final.serviceConfig; [
          ExecStartPre
          ExecStart
        ];
        serviceConfig = {
          ExecStartPre = pkgs.writeShellScript "generate-mpris-discord-rpc-config" ''
            freeimage_api_key=$(cat ${config.sops.secrets."freeimage_api".path});
            [[ -n "$freeimage_api_key" ]]
            discord_client_id=$(cat ${config.sops.secrets."discord_client_id".path});
            [[ -n "$discord_client_id" ]]

            config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/mpris-discord-rpc"
            config_file="''${config_dir}/config.yaml"
            rm -vrf $config_dir | true
            mkdir -p "$config_dir"
            # all json is valid yaml
            echo ${escapeShellArg <| builtins.toJSON settings} | \
              ${getExe pkgs.jq} \
              --arg freeimage_api_key "$freeimage_api_key" \
              --arg discord_client_id "$discord_client_id" \
              '. + {freeimage_api_key: $freeimage_api_key, discord_client_id: $discord_client_id}' > "$config_file"
          '';

          ExecStart = getExe self.packages.${system}.mpris-discord-rpc;
          RestartSec = 10;
        };
      });
    };
}
