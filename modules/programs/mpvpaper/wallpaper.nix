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
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) rong-impure xdg-base-dir;
          inherit (pkgs) fd;
        };
        text = /* nu */ ''
          def main [
              wallpaper?: string,
              --color (-c): string
          ] {
              let wallpaper_dir = xdg-base-dir user-videos | path join "wallpapers"
              let state_file = xdg-base-dir state-file "wallpaper/state"

              let input = if $wallpaper != null {
                  $wallpaper
              } else {
                  find_wallpaper $wallpaper_dir
              }


              print $"Setting wallpaper ($input)"

              # update the wallpapers timestamp (used for quickshell sorting)
              touch $input

              mkdir ($state_file | path dirname)
              $input | save --force $state_file

              if $color != null {
                  rong video --source-color $color -v $input
              } else {
                  rong video -v $input
              }
          }

          def find_wallpaper [wallpaper_dir: string] {
              mkdir $wallpaper_dir
              # This will error if no item is found
              fd '\.(mp4|mkv|webm|gif)$' $wallpaper_dir | lines | shuffle | get 0
          }
        '';
      };
  };
}
