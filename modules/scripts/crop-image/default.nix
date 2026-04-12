_:
let
  name = "crop-image";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-r, --ratio=" = "Ratio of the output image. (Required) E.g. 16:9 2/1 1.5";
        "--help" = "Show help menu for ${name}";
      };
      completion.positionalany = [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          imagemagick
          coreutils
        ];
        source = ./crop-image.nu;
      };
  };
}
