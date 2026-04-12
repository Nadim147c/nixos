let
  name = "qs-weather";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [ jq ];
        source = ./qs-weather.nu;
      };
  };
}
