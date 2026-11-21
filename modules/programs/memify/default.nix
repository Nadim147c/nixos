{ lib, ... }:
{
  perSystem = { inputs', ... }: {
    packages.memify = inputs'.memify.packages.memify;
  };

  flake.tree.nixos.gui.memify = { inputs', ... }: {
    hj.xdg.config.files."carapace/specs/memify.yaml" = {
      generator = lib.generators.toYAML { };
      value = {
        name = "memify";
        flags = {
          "-h, --help" = "Display the help message for this command";
          "-t, --top=" = "Add text to the top";
          "-b, --bottom=" = "Add text to the bottom";
          "-l, --left=" = "Add text to the left";
          "-r, --right=" = "Add text to the right";
          "-p, --padding=" = "Padding around the text";
          "-a, --ratio=" = "Aspect ratio of text image";
          "-f, --font=" = "Text font to use";
          "-o, --output=" = "Output path";
          "-g, --gif" = "Output as GIF";
        };
        completion = {
          flag = {
            output = [ "$files" ];
          };
          positional = [
            [ "$files" ]
          ];
        };
      };
    };
    packages = lib.singleton inputs'.memify.packages.memify;
  };
}
