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
        pkgs.gtk3
        pkgs.uwsm
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
    in
    {

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
        flagSeparator = "=";
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
        serviceConfig = {
          ExecStart = getExe self.packages."${system}".quickshell;
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };
}
