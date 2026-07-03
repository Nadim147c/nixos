let
  name = "fpsearch";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion.positional = [
        [ "$files" ]
        [ "$files" ]
      ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          chromaprint
        ];
        source = ./fpsearch.nu;
      };
  };
}
