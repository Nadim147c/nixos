{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib)
    toList
    attrValues
    cleanSource
    filterAttrs
    getExe
    hasPrefix
    makeBinPath
    ;
  inherit (lib.fileset) toSource unions;
  inherit (lib.x) singleton;
in
{
  perSystem =
    {
      pkgs,
      self',
      system,
      ...
    }:
    let
      discord-voice-rpc = inputs.discord-voice-rpc.packages.${system}.default;

      buildInputs = with pkgs; [
        kdePackages.qt5compat
        kdePackages.qtdeclarative
        qt6.qtimageformats
        qt6.qtmultimedia
        qt6.qtsvg
        self'.packages.qt-m3shapes
      ];

      quickshellScripts = self'.packages |> filterAttrs (name: _: hasPrefix "qs-" name) |> attrValues;
      extraBinaries = quickshellScripts ++ [
        self'.packages.hyprscreenshot
        self'.packages.rong-impure
        self'.packages.wallpaper
        self'.packages.waybar-lyric-impure
        self'.packages.yankd-impure
        self'.packages.control
        self'.packages.app-launcher
        pkgs.hyprshutdown
        discord-voice-rpc
      ];

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
          (makeBinPath extraBinaries)
        ];
        flags."--path" = toString quickshellConfig;
      };
    };

  flake.modules.nixos.gui =
    {
      config,
      system,
      ...
    }:
    {
      packages = [
        self.packages.${system}.quickshell
      ];

      programs.rong.settings.installs = {
        "quickshell.json" = "${config.home.xdg.state.directory}/quickshell/colors.json";
      };

      home.systemd.services.quickshell = rec {
        enable = true;
        description = "mpvpaper control daemon";
        partOf = toList "graphical-session.target";
        after = partOf;
        wantedBy = partOf;
        reloadTriggers = toList self.packages."${system}".quickshell;
        serviceConfig = {
          ExecStart = getExe self.packages."${system}".quickshell;
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };
}
