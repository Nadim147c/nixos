{ lib, ... }:
let
  name = "tmux-navigate";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion = {
        positional = [ (lib.splitString " " "left right up down h j k l") ];
      };
    };
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./tmux-navigate.go);
  };
}
