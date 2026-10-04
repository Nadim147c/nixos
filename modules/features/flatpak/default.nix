{ inputs, lib, ... }:
let
  inherit (lib) singleton;
in
{
  flake.modules.nixos.gui = { config, ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    preserve.directories = singleton "/var/lib/flatpak";
    preserveHome.directories = [
      ".cache/flatpak"
      ".local/share/flatpak"
      ".var/app"
    ];

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
        global = {
          Context.filesystems = [
            "/nix/store:ro"
            "/run/current-system/sw/share:ro"
            "xdg-download"
            "xdg-config/gtkrc-2.0"
            "xdg-config/gtk-3.0"
            "xdg-config/gtk-4.0"
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
