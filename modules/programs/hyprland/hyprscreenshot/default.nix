{ self, ... }:
let
  name = "hyprscreenshot";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion.positional = [
        [
          "region"
          "screen"
        ]
      ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          grim
          libnotify
          satty
          slurp
          wl-clipboard
          self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-base-dir
        ];
        source = ./hyprscreenshot.nu;
      };
  };
}
