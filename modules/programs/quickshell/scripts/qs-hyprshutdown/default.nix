let
  name = "qs-hyprshutdown";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          findutils
          gnugrep
          hyprland
          jq
        ];
        text = builtins.readFile ./qs-hyprshutdown.sh;
      };
  };
}
