{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) toList getExe getExe';
  inherit (lib.x) quote;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      center-screenshot = pkgs.writers.writePython3Bin "center-screenshot" {
        libraries = [ pkgs.python3Packages.wand ];
        makeWrapperArgs = [ "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.imagemagick ]}" ];
      } (builtins.readFile ./center_screenshot.py);

      xdg-base-dir = getExe self'.packages.xdg-base-dir;
      date = getExe' pkgs.uutils-coreutils-noprefix "date";
    in
    {
      packages.chroma = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.chroma;
        flags = {
          "--style" = ./tokionight-moon.xml;
          "--formatter" = "terminal16m";
        };
      };

      packages.freeze = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.charm-freeze;
        runShell = toList /* bash */ ''
          screenshot_file="$(${xdg-base-dir} user-pictures)/freeze/$(${date} +'%Y-%m-%d_%H-%M-%S').png"
          mkdir -p "$(dirname "$screenshot_file")"
        '';
        flags = {
          "--theme" = "tokionight-moon";
          "--output" = {
            data = "$screenshot_file";
            esc-fn = quote;
          };
        };
        flagSeparator = "=";
      };

      packages.termshot = pkgs.writeShellApplication {
        name = "termshot";
        runtimeInputs = [
          center-screenshot
          self'.packages.xdg-base-dir
          pkgs.uutils-coreutils-noprefix
          pkgs.chafa
          pkgs.charm-freeze
          pkgs.uutils-coreutils-noprefix
          pkgs.wl-clipboard
        ];
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

          freeze "$@" --theme=rose-pine --output="$temp_screenshot"

          center-screenshot "$temp_screenshot" "$screenshot_file"

          wl-copy < "$screenshot_file"

          chafa "$screenshot_file"
        '';
      };

    };

  flake.modules.nixos.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) freeze termshot chroma;
    in
    {
      packages = [
        chroma
        freeze
        termshot
      ];
    };
}
