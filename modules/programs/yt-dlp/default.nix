{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) toList getExe getExe';
  inherit (lib.x) quote;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      videoSettings = {
        color = "always";
        concurrent-fragments = 4;
        embed-chapters = true;
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;
        format = "(bv*[height<=1080]+ba*)/(b[height<=1080])/b";
        list-formats = true;
        merge-output-format = "mp4";
        output = "%(title)s-%(id)s.%(ext)s";
        simulate = false;
        sponsorblock-mark = "all";
        sub-langs = "all";
      };

      audioSettings = {
        color = "always";
        concurrent-fragments = 4;
        embed-chapters = false;
        embed-metadata = false;
        embed-subs = false;
        embed-thumbnail = false;
        format = "ba/ba*/b";
        list-formats = true;
        output = "%(title)s-%(id)s.%(ext)s";
        extract-audio = true;
        recode-video = "opus";
        simulate = false;
        sponsorblock = false;
      };

    in
    {
      packages.yt-dlp = inputs.wrappers.wrappers.yt-dlp.wrap {
        inherit pkgs;
        package = pkgs.yt-dlp;
        flags."--paths" = {
          data = "$(${getExe self'.packages.xdg-base-dir} user-download)";
          esc-fn = quote;
        };
        settings = videoSettings;
      };
      packages.yt-dlm = inputs.wrappers.wrappers.yt-dlp.wrap {
        inherit pkgs;
        package = pkgs.yt-dlp;
        flags."--paths" = {
          data = "$(${getExe self'.packages.xdg-base-dir} user-download)";
          esc-fn = quote;
        };
        filesToExclude = [ "bin/yt-dlp" ];
        binName = "yt-dlm";
        settings = audioSettings;
      };
    };

  flake.modules.nixos.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) yt-dlp yt-dlm;
    in
    {
      packages = [
        yt-dlp
        yt-dlm
      ];
    };
}
