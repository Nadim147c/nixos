{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    cleanSource
    filterAttrs
    fix
    getExe
    hasPrefix
    makeBinPath
    singleton
    ;
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
        inherit (self'.packages) qt-m3shapes;
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
        Quickshell cannot natively execute .desktop files, and its
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
    {
      packages.app-launcher = pkgs.runCommand "app-launcher" { } ''
        mkdir -p $out/bin
        ln -s ${app-launcher}/bin/app-launcher $out/bin/app-launcher
      '';

      packages.quickshell = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = (pkgs.lib.flakePackage inputs.quickshell).overrideAttrs (oldAttrs: {
          buildInputs = buildInputs ++ oldAttrs.buildInputs;
        });
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
        "quickshell.json" = "${config.home.xdg.state.directory}/quickshell/colors.json";
      };

      home.systemd.services.quickshell = fix (final: {
        enable = true;
        description = "mpvpaper control daemon";
        partOf = singleton "graphical-session.target";
        wants = singleton "tray.target";
        before = final.partOf;
        after = final.partOf;
        wantedBy = final.partOf;
        reloadTriggers = singleton self.packages."${system}".quickshell;
        serviceConfig = {
          ExecStart = getExe self.packages."${system}".quickshell;
          Restart = "on-failure";
          RestartSec = 10;
        };
      });
    };
}
