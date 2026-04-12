{ self, ... }:
let
  name = "qs-screenrecord";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      let
        ffmpeg-progress = self.packages.${pkgs.stdenv.hostPlatform.system}.qs-ffmpeg-compress-progress;
      in
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          coreutils
          ffmpeg
          gum
          jq
          libnotify
          slurp
          wf-recorder
          ffmpeg-progress
        ];

        text = builtins.readFile ./qs-screenrecord.sh;
      };
  };
}
