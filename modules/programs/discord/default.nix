{ self, lib, ... }:
let
  inherit (lib.meta) getExe;
  inherit (lib.strings) escapeShellArg;
  inherit (lib.lists) singleton;
  appId = "com.discordapp.Discord";
in
{
  flake.tree.nixos.gui.discord =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      inherit (self.packages.${system}) control;
    in
    {
      services.flatpak = {
        packages = singleton appId;
        overrides.settings."${appId}" = {
          Context.filesystems = [
            "xdg-config/discord"
            "xdg-config/Equicord"
            "${config.hj.directory}/.portal"
            "!xdg-config"
            "!xdg-data"
            "!xdg-download"
            "!xdg-music"
            "!xdg-pictures"
            "!xdg-videos"
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "L+ /run/user/1000/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"
      ];

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
        enable = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = false;
          ExecStart =
            let
              app_asar = pkgs.runCommand "app.asar" { } ''
                mkdir -p "$out"
                echo '{"name":"discord","main":"index.js"}' > "$out/package.json"
                echo "require(\"${pkgs.equicord}/desktop/patcher.js\")" > "$out/index.js"
              '';
            in
            pkgs.writers.writeNu "install-equicord-discord" /* nu */ ''
              let target = "/var/lib/flatpak/app/com.discordapp.Discord/current/active/files/discord"

              if not ($target | path exists) {
                return
              }

              let app_asar = $"($target)/resources/app.asar"
              let app_asar_copy = $"($target)/resources/_app.asar"

              if (test -f $app_asar | complete | get exit_code) == 0 {
                mv --verbose --force $app_asar $app_asar_copy
              }

              rm --recursive --force --verbose $app_asar
              cp --recursive --force --verbose ${app_asar} $app_asar
            '';
        };
        wantedBy = [
          "default.target"
          "sysinit-reactivation.target"
        ];
        before = singleton "sysinit-reactivation.target";
      };

      hj.xdg.mime-apps = lib.x.genMimes "discord.desktop" [ "x-scheme-handler/discord" ];
      hj.xdg.config.files."Equicord/settings/settings.json" = {
        type = "copy";
        permissions = "644";
        source = ./settings.json;
      };
    };
}
