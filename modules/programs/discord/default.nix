{ self, lib, ... }:
let
  inherit (lib.meta) getExe;
  inherit (lib.strings) escapeShellArg;
  inherit (lib.lists) singleton;
  appId = "com.discordapp.Discord";
in
{
  flake.modules.nixos.gui =
    { pkgs, system, ... }:
    let
      inherit (self.packages.${system}) control;
    in
    {
      preserveHome.directories = [
        ".config/discord"
        ".config/Equicord"
      ];

      services.flatpak = {
        packages = singleton appId;
        overrides."${appId}" = {
          Context.filesystems = [
            "xdg-config/discord"
            "xdg-config/Equicord"
            "!xdg-config"
            "!xdg-data"
            "!xdg-videos"
            "!xdg-pictures"
            "!xdg-music"
            "!xdg-download"
          ];
        };
      };

      hj.programs.hyprland = {
        windowRules = singleton {
          name = "discord workspace 3";
          match.class = "^(discord)$";
          workspace = "3 silent";
        };
        programs = singleton {
          keys = [
            "SUPER"
            "D"
          ];
          autostart = true;
          exec = "${getExe control} --memory=800M --cpu=80% -- flatpak run ${escapeShellArg appId}";
        };
      };

      hj.xdg.config.files."rong/templates/discord.css.tmpl".source = pkgs.replaceVars ./theme.css {
        font = "Pixelify Sans";
        code-font = "JetBrainsMono Nerd Font";
        colors = "off";
      };

      programs.rong.settings.themes = singleton {
        target = "discord.css";
        links = "~/.config/Equicord/settings/quickCss.css";
      };

      systemd.services.install-equicord-discord = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = false;
        };
        wantedBy = [
          "default.target"
          "sysinit-reactivation.target"
        ];
        before = singleton "sysinit-reactivation.target";
        script = ''
          set -euo pipefail
          TARGET="/var/lib/flatpak/app/com.discordapp.Discord/current/active/files/discord"

          [[ ! -d "$TARGET" ]] && exit 1

          if [[ -f "$TARGET/resources/app.asar" && ! -e "$TARGET/resources/_app.asar" ]]; then
            mv -vf "$TARGET/resources/app.asar" "$TARGET/resources/_app.asar"
          fi

          mkdir -p "$TARGET/resources/app.asar"
          echo '{"name":"discord","main":"index.js"}' > "$TARGET/resources/app.asar/package.json"
          echo "require(\"${pkgs.equicord}/desktop/patcher.js\")" > "$TARGET/resources/app.asar/index.js"
        '';
      };

      hj.xdg.mime-apps = lib.x.genMimes "discord.desktop" [ "x-scheme-handler/discord" ];
      hj.xdg.config.files."Equicord/settings/settings.json" = {
        type = "copy";
        permissions = "644";
        source = ./settings.json;
      };
    };
}
