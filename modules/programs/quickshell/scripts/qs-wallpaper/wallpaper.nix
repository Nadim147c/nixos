{ self, ... }:
let
  name = "wallpaper";
in
{
  scripts."${name}" = {

    inherit name;
    completion = {
      inherit name;
      flags = {
        "-c, --color=" = "Use color to generate themes";
      };
      completion.positional = [ [ "$files" ] ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        inheritPath = true;
        runtimeInputs = builtins.attrValues {
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system})
            qs-wallpaper
            rong-impure
            xdg-base-dir
            ;
          inherit (pkgs) hyprland fd;
        };
        source = ./wallpaper.nu;
      };
  };
}
