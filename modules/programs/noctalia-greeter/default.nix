{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config) username;
  inherit (lib) singleton;
in
{
  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      settings = {
        appearance = {
          scheme = "Synced";
          password_style = "random";
          theme_mode = "dark";
          font_family = config.custom.font.sans;
        };
        cursor = {
          theme = config.cursor.name;
          size = config.cursor.size;
          path = "${config.cursor.package}/share/icons";
        };
        keyboard = {
          layout = "us";
        };
      };

      package = inputs.noctalia-greeter.packages.${system}.default;

      script = pkgs.writers.writeNu "update-noctalia-colors" /* nu */ ''
        let colors = open /tmp/noctalia.json

        let palette = $colors.colors
          | upsert name {|it| $it.name.snake }
          | upsert value {|it| $it.value.hex_rgb }
          | rename key valu
          | transpose --header-row --as-record
          | select primary on_primary secondary on_secondary tertiary on_tertiary error on_error surface on_surface surface_variant on_surface_variant outline shadow
          | upsert hover $colors.material.secondary.hex_rgb
          | upsert on_hover $colors.material.on_secondary.hex_rgb

        let config = echo /var/lib/noctalia-greeter/greeter.toml

        open $config
        | upsert appearance.palette $palette
        | collect
        | save --force $config
      '';

      target = "/tmp/noctalia.json";

      user = config.services.greetd.settings.default_session.user;
      group =
        if config.users.users.${user}.group != "" then config.users.users.${user}.group else "greeter";
    in
    {
      imports = singleton inputs.noctalia-greeter.nixosModules.default;
      preserve.directories = singleton "/var/lib/noctalia-greeter";

      programs.rong.settings.themes = singleton {
        target = "colors.json";
        installs = target;
      };

      systemd.services.noctalia-theme-update = {
        description = "Update Noctalia Greeter theme from JSON palette";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${script}";
        };
      };

      systemd.paths.noctalia-theme-update = {
        description = "Monitor /tmp/noctalia.json for theme changes";
        wantedBy = singleton "multi-user.target";
        pathConfig = {
          PathChanged = target;
          Unit = "noctalia-theme-update.service";
        };
      };

      services.greetd = {
        enable = true;
        settings.default_session.user = username;
        settings.default_session.command = "${package}/bin/noctalia-greeter-session";
      };

      services.accounts-daemon.enable = true;

      systemd.tmpfiles.settings."10-noctalia-greeter" = {
        "/var/lib/noctalia-greeter".d = {
          inherit user group;
          mode = "0750";
        };
        "/var/lib/noctalia-greeter/greeter.toml"."C" = {
          argument = "${pkgs.writers.writeTOML "noctalia.toml" settings}";
          inherit user group;
        };
      };
    };
}
