{ self, lib, ... }:
let
  inherit (lib.meta) getExe;
  inherit (lib.strings) escapeShellArg;
  inherit (lib.lists) singleton;
  appId = "org.freesmlauncher.FreesmLauncher";
in
{
  flake.modules.nixos.game =
    { pkgs, ... }:
    {
      # needed from freesmlauncher
      packages = with pkgs; [
        libxcb-cursor
        libxcb
        xcb-util-cursor
      ];

      services.flatpak = {
        packages = [
          "org.freedesktop.Platform.VulkanLayer.MangoHud//24.08"
          {
            inherit appId;
            origin = "freesmlauncher";
          }
        ];

        remotes = singleton {
          name = "freesmlauncher";
          location = "https://flatpak.freesmlauncher.org/freesmlauncher.flatpakrepo";
        };
        # overrides."${appId}" = { };
      };

    };
}
