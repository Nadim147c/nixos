{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (lib) mkForce getExe escapeShellArg;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      playerInfo = getExe self'.packages.hyprlock-player-info;
      fancy = "Electroharmonix";
      icon = "JetBrainsMono Nerd Font Propo";
      main = "Roboto Flex";
      fallback = "Noto Font";
      rongTemplate = escapeShellArg ''
        # Generated using rong: https://github.com/Nadim147c/rong (GPL-3.0)
        $image = {{ .Image }}
        {{ range .Colors -}}
        ''${{ .Name.Snake }} = rgba({{ .Color.TrimmedHexRGBA }})
        ''${{ .Name.Snake -}}_hex = #{{ .Color.HexRGB }}
        {{ end -}}
      '';
      rongBin = getExe self'.packages.rong-impure;
    in
    {
      packages.hyprlock = inputs.wrappers.wrappers.hyprlock.wrap (args: {
        inherit pkgs;
        package = pkgs.hyprlock;
        importantPrefixes = [
          "$"
          "bezier"
          "monitor"
          "size"
          "source"
        ];
        runShell = [
          /* bash */ ''
            # Assemble hyprlock config: user overrides (if any) + wallpaper colors + base Nix config
            # Final config written to temporary file at $HYPRLOCK_CONFIG

            rong_hyprland_config="''${XDG_STATE_HOME:-$HOME/.local/state}/rong/hyprland.conf"
            base_hyprlock_config=${args.config."hyprlock.conf".path}
            export HYPRLOCK_CONFIG=$(mktemp)

            if [[ -f "$rong_hyprland_config" ]]; then
              # User has custom hyprland colors → use them instead of wallpaper-generated ones
              cat "$rong_hyprland_config" "$base_hyprlock_config" > "$HYPRLOCK_CONFIG"
            else
              # Generate colors from wallpaper + use base config as fallback
              cat <(${rongBin} image --dry-run --template=${rongTemplate} ${./../../../wallpaper.png}) "$base_hyprlock_config" > "$HYPRLOCK_CONFIG"
            fi
          ''
        ];
        flags."--config" = mkForce {
          data = "$HYPRLOCK_CONFIG";
          esc-fn = lib.x.quote;
        };
        settings = {
          background = {
            monitor = "";
            path = "$image";
            color = "$background";
            blur_passes = 2;
            contrast = 1.0;
            brightness = 0.5;
            vibrancy = 0.2;
            vibrancy_darkness = 0.2;
          };

          general = {
            hide_cursor = false;
          };

          input-field = {
            monitor = "";
            size = "250,60";
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.35;
            dots_center = true;
            outer_color = "$outline";
            inner_color = "$background";
            font_color = "$on_background";
            fade_on_empty = false;
            fail_color = "$error";
            check_color = "$primary";
            rounding = -1;
            placeholder_text = ''<i><span foreground="$primary_hex">Password</span></i>'';
            hide_input = false;
            position = "0, -70";
            halign = "center";
            valign = "center";
          };

          label = [
            # Time label
            {
              monitor = "";
              text = "cmd[update:1000] date +\"%-I:%M%p\"";
              color = "$on_background";
              font_size = 95;
              font_family = "${fancy}, ${fallback}";
              position = "0, 120";
              halign = "center";
              valign = "center";
            }

            # Date label
            {
              monitor = "";
              text = "cmd[update:1000] date +\"%A, %B %d\"";
              color = "$primary";
              font_size = 16;
              font_family = "${main}, ${fallback}";
              position = "0, 50";
              halign = "center";
              valign = "center";
            }

            # Current song label
            {
              monitor = "";
              text = "cmd[update:1000] ${playerInfo}";
              color = "$on_background";
              font_size = 12;
              font_family = "${main}, ${icon}, monospace, ${fallback}";
              position = "0, 50";
              halign = "center";
              valign = "bottom";
            }

            # Greeting label
            {
              monitor = "";
              text = "Hi, ${config.fullname}";
              color = "$on_background";
              font_size = 14;
              font_family = "${main}, ${fallback}";
              position = "0, -10";
              halign = "center";
              valign = "center";
            }
          ];
        };
      });
    };

  flake.modules.nixos.gui = {
    security.pam.services.hyprlock.enable = true;
  };

  flake.modules.homeManager.gui =
    { pkgs, system, ... }:
    {
      home.packages = with pkgs; [
        self.packages.${system}.electroharmonix
        nerd-fonts.jetbrains-mono
        roboto-flex
      ];

      programs.hyprlock = {
        enable = true;
        package = self.packages.${system}.hyprlock;
      };
    };
}
