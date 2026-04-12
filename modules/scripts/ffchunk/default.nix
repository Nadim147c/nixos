{ ... }:
let
  name = "ffchunk";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-t, --time=" = "Length of each chunk";
        "-d, --delete" = "Delete original after processing file";
        "--help" = "Show help menu for ${name}";
      };
      completion.positionalany = [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeNuApplication {
        name = "ffchunk";
        runtimeInputs = [ pkgs.ffmpeg ];
        source = ./ffchunk.nu;
      };
  };
}
