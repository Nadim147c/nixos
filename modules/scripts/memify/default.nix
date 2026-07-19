{ lib, ... }:
let
  inherit (lib) singleton;
  name = "memify";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-p, --padding=" = "Padding around the text";
        "-a, --ratio=" = "Aspect ratio of text image";
        "-g, --gravity=" = "Text gravity";
        "-f, --font=" = "Text font to use";
        "-t, --top=" = "Add text to the top";
        "-b, --bottom=" = "Add text to the bottom";
        "-l, --left=" = "Add text to the left";
        "-r, --right=" = "Add text to the right";
      };
      completion = {
        flag.gravity = [
          "northwest"
          "north"
          "northeast"
          "west"
          "center"
          "east"
          "southwest"
          "south"
          "southeast"
        ];
        positionalany = singleton [ "files" ];
      };
    };
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./memify.go);
  };
}
