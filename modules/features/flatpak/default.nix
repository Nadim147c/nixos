{ inputs, lib, ... }:
let
  inherit (lib)
    importJSON
    singleton
    mkOption
    types
    ;

  readonly =
    values:
    mkOption {
      type = types.attrs;
      readOnly = true;
      default = values;
    };
in
{
  options.flake.flatpak.apps = readonly <| importJSON ./apps.json;
  config.flake.tree.nixos.gui.flatpak = { config, ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak = {
      enable = true;
      packages = [ "com.github.tchx84.Flatseal" ];
      uninstallUnmanaged = true;
      update.auto = {
        enable = true;
        onCalendar = "Fri,Wed 22:00:00";
      };
      remotes = singleton {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
      overrides = {
        pruneUnmanagedOverrides = true;
        writeMode = "replace";
        settings.global = {
          Context.filesystems = [
            "/nix/store:ro"
            "/run/current-system/sw/share:ro"
            "xdg-config/gtkrc-2.0"
            "xdg-config/gtk-3.0"
            "xdg-config/gtk-4.0"
            "${config.hj.directory}/.portal"
            "!xdg-download"
            "!xdg-config"
            "!xdg-data"
            "!xdg-videos"
            "!xdg-pictures"
            "!xdg-music"
            "!xdg-download"
          ];
          Context.sockets = [
            "wayland"
            "!x11"
            "!fallback-x11"
          ];
          Environment = {
            inherit (config.environment.sessionVariables) GTK_THEME;
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          };
        };
      };
    };

  };
}
