let
  name = "opustag-fix";
in
{
  scripts."${name}" = rec {
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
        runtimeInputs = with pkgs; [ opustags ];
        source = ./opustag-fix.nu;
      };
  };
}
