{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
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
        paths = "\${XDG_DOWNLOAD_DIR}";
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
        paths = "\${XDG_DOWNLOAD_DIR}";
        # recode-video = "mp3";
        simulate = false;
        sponsorblock = false;
      };

      env."XDG_DOWNLOAD_DIR" = {
        data = "\${XDG_DOWNLOAD_DIR:-$HOME/Videos}/";
        esc-fn = x: ''"${x}"'';
      };
    in
    {
      packages.yt-dlp = inputs.wrappers.wrappers.yt-dlp.wrap (_: {
        inherit pkgs;
        package = pkgs.yt-dlp;
        envDefault = env;
        settings = videoSettings;
      });
      packages.yt-dlm = inputs.wrappers.wrappers.yt-dlp.wrap (_: {
        inherit pkgs;
        package = pkgs.yt-dlp;
        filesToExclude = [ "bin/yt-dlp" ];
        binName = "yt-dlm";
        settings = audioSettings;
      });
    };

  flake.modules.homeManager.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) yt-dlp yt-dlm;
    in
    {
      home.packages = [
        yt-dlp
        yt-dlm
      ];
    };
}
