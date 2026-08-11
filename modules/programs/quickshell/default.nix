{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib.attrsets) attrValues filterAttrs;
  inherit (lib.fixedPoints) fix;
  inherit (lib.lists) singleton;
  inherit (lib.strings) hasPrefix;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.sources) cleanSource;
  inherit (lib.strings) makeBinPath;
  inherit (lib.fileset) toSource unions;
in
{
  perSystem =
    {
      pkgs,
      self',
      inputs',
      ...
    }:
    let
      discord-voice-rpc = inputs'.discord-voice-rpc.packages.default;

      buildInputs = attrValues {
        inherit (pkgs.kdePackages) qt5compat qtdeclarative;
        inherit (pkgs.qt6) qtimageformats qtmultimedia qtsvg;
        inherit (self'.packages) qt-m3shapes qt-oklab qt-cava;
      };

      quickshellScripts = self'.packages |> filterAttrs (name: _: hasPrefix "qs-" name) |> attrValues;
      runtimeInputs =
        attrValues {
          inherit (pkgs) hyprshutdown pavucontrol;
          inherit (self'.packages)
            hyprscreenshot
            rong-impure
            wallpaper
            waybar-lyric-impure
            yankd-impure
            control
            app-launcher
            ;
          inherit discord-voice-rpc;
        }
        ++ quickshellScripts;

      quickshellConfig = cleanSource (toSource {
        root = ./.;
        fileset = unions [
          ./modules
          ./shell.qml
        ];
      });

      /*
        Quickshell cannot natively execute `.desktop` files, and its
        systemd service does not inherit the system PATH. This
        wrapper uses `uwsm` to handle the application launching,
        explicitly exposing the system PATH so desktop apps can
        be resolved and spawned correctly.
      */
      app-launcher = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.uwsm;
        binName = "app-launcher";
        addFlag = [
          "app"
          "-t"
          "service"
          "--"
        ];
        prefixVar = singleton [
          "PATH"
          ":"
          "/run/wrappers/bin:/run/current-system/sw/bin"
        ];
      };
    in
    mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.app-launcher = pkgs.runCommand "app-launcher" { } ''
        mkdir -p $out/bin
        ln -s ${app-launcher}/bin/app-launcher $out/bin/app-launcher
      '';

      packages.quickshell = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = (pkgs.lib.flakePackage inputs.quickshell).overrideAttrs (oldAttrs: {
          buildInputs = buildInputs ++ oldAttrs.buildInputs;
        });
        env.FONTCONFIG_DIR = "${self'.packages.systemFonts}";
        prefixVar = singleton [
          "PATH"
          ":"
          (makeBinPath runtimeInputs)
        ];
        flags."--path" = toString quickshellConfig;
      };
    };

  flake.modules.nixos.gui =
    { config, system, ... }:
    {
      packages = [
        self.packages.${system}.quickshell
        inputs.discord-voice-rpc.packages.${system}.default
      ];

      programs.rong.settings.installs = {
        "quickshell.json" = "${config.hj.xdg.state.directory}/quickshell/colors.json";
      };

      hj.systemd.services.quickshell = fix (final: {
        enable = true;
        description = "mpvpaper control daemon";
        partOf = singleton "graphical-session.target";
        wantedBy = final.partOf;
        wants = [
          "tray.target"
          "pipewire.service"
          "wireplumber.service"
        ];
        after = final.wants;
        reloadTriggers = singleton self.packages."${system}".quickshell;
        serviceConfig = {
          ExecStart = getExe self.packages."${system}".quickshell;
          Restart = "on-failure";
          RestartSec = 10;
        };
      });
    };
}
