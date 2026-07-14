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
    script =
      pkgs:
      let
        args.runtimeInputs = [ pkgs.tmux ];
      in
      pkgs.writers.writeGoBin name args (builtins.readFile ./tmux-navigate.go);
  };
}
