let
  name = "nix-update-file";
in
{
  scripts."${name}" = {
    completion = {
      inherit name;
      flags = {
        "--unstable" = "Use latest commit of current branch";
      };
      completion.positional = [ [ "$files" ] ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          git
          nix-update
        ];
        source = ./nix-update-file.nu;
      };
  };
}
