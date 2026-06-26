{ inputs, lib, ... }:
let
  inherit (lib.x) singleton;
  inherit (lib) makeBinPath;
  name = "qs-screenrecord";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.writers.writeGoBin name (builtins.readFile ./qs-screenrecord.go);
        prefixVar = singleton [
          "PATH"
          ":"
          (makeBinPath [
            pkgs.pulseaudio
            pkgs.ffmpeg
            pkgs.libnotify
            pkgs.slurp
            pkgs.wf-recorder
          ])
        ];
      };
  };
}
