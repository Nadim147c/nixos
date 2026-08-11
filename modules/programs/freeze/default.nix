{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.attrsets) attrValues;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.x) makeEnvFlag;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      center-screenshot = pkgs.writers.writePython3Bin "center-screenshot" {
        libraries = singleton pkgs.python3Packages.wand;
        makeWrapperArgs = [ "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.imagemagick ]}" ];
      } (builtins.readFile ./center_screenshot.py);

      xdg-base-dir = getExe self'.packages.xdg-base-dir;
    in
    {
      packages.chroma = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.chroma;
        flags = {
          "--style" = ./chroma-tokionight-moon.xml;
          "--formatter" = "terminal16m";
        };
      };

      packages.freeze = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.charm-freeze.overrideAttrs (final: {
          patches = [ ./freeze-tokyonight.patch ];
          doCheck = false;
        });
        runShell = singleton /* bash */ ''
          screenshot_file="$(${xdg-base-dir} user-pictures)/freeze/$(date +'%Y-%m-%d_%H-%M-%S').png"
          mkdir -p "$(dirname "$screenshot_file")"
        '';
        flags = {
          "--theme" = ./chroma-tokionight-moon.xml;
          "--output" = makeEnvFlag "screenshot_file";
        };
      };

      packages.termshot = pkgs.writeShellApplication {
        name = "termshot";
        runtimeInputs = attrValues {
          inherit center-screenshot;
          inherit (pkgs) chafa coreutils wl-clipboard;
          inherit (self'.packages) freeze xdg-base-dir;
        };
        text = ''
          screenshot_file="$(xdg-base-dir user-pictures)/freeze/$(date +'%Y-%m-%d_%H-%M-%S').png"
          mkdir -p "$(dirname "$screenshot_file")"
          printf "Creating screenshot -> %q\n" "$screenshot_file"

          temp_dir=$(mktemp -d)
          temp_screenshot="$temp_dir/screenshot.png"

          cleanup() {
            rm -vrf "$temp_dir"
          }
          trap cleanup EXIT

          freeze "$@" --output="$temp_screenshot"

          center-screenshot "$temp_screenshot" "$screenshot_file"

          wl-copy < "$screenshot_file"

          chafa "$screenshot_file"
        '';
      };

    };

  flake.modules.nixos.base = { system, ... }: {
    packages = with self.packages.${system}; [
      chroma
      freeze
      termshot
    ];
  };
}
