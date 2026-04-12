{
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib)
    nameValuePair
    flatten
    genAttrs'
    optional
    ;
in
{
  perSystem =
    { pkgs, ... }:
    let
      createScripts = scripts: genAttrs' scripts (script: nameValuePair script.pname { path = script; });
    in
    {
      packages.mpv = inputs.wrappers.wrappers.mpv.wrap (_: {
        inherit pkgs;
        package = pkgs.mpv;
        script = createScripts (
          (with pkgs.mpvScripts; [
            modernx
            quality-menu
            sponsorblock
            thumbfast
          ])
          ++ optional pkgs.stdenv.hostPlatform.isLinux pkgs.mpvScripts.mpris
        );

        "mpv.conf".content = /* ini */ ''
          vo=gpu
          osc=no
          save-position-on-quit=yes
          keep-open=yes
          sub-fix-timing=yes
          blend-subtitles=yes
          sub-auto=fuzzy
          slang=en,eng,enUS,en-US
          user-agent=Mozilla/5.0

          # script-opts and ytdl-raw-options require specific formatting
          script-opts=ytdl_hook-ytdl_path=yt-dlp,ytdl_hook-try_ytdl_first=yes
          ytdl-raw-options=sub-lang="en,eng,enUS,en-US",write-sub=,write-auto-sub=,yes-playlist=,concurrent-fragments=4
        '';
        "mpv.input".content = /* sh */ ''
          ctrl+f        script-binding quality_menu/video_formats_toggle
          .             cycle-values video-aspect "16:9" "4:3" "2.35:1" "-1"
          s             cycle-values sub-pos 100 60
          ENTER         cycle-values fullscreen yes no
          KP_ENTER      cycle-values fullscreen yes no
          MOUSE_BTN1    cycle-values fullscreen yes no
          MOUSE_BTN0    cycle pause
          CTRL+UP       add sub-font-size 2
          CTRL+DOWN     add sub-font-size -2
          UP            add volume 2
          DOWN          add volume -2
          KP4           playlist-prev
          KP6           playlist-next
          <             add sub-delay -0.1
          >             add sub-delay +0.1
          *             set speed 1
          +             add speed +0.1
          KP_ADD        add speed +0.1
          -             add speed -0.1
          KP_SUBTRACT   add speed -0.1
        '';
      });
    };

  flake.modules.homeManager.gui =
    { pkgs, ... }:
    let
      createMimesList =
        prefix: mimes: mimes |> builtins.split "[[:space:]]+" |> flatten |> map (mime: "${prefix}/${mime}");

      audioMimes = createMimesList "audio" ''
        aac mp4 mpeg mpegurl ogg vnd.rn-realaudio
        vorbis x-flac x-mp3 x-mpegurl x-ms-wma
        x-musepack x-oggflac x-pn-realaudio x-scpls
        x-vorbis x-vorbis+ogg x-wav
      '';
      videoMimes = createMimesList "video" ''
        3gp 3gpp 3gpp2 avi divx dv fli flv mp2t
        mp4 mp4v-es mpeg msvideo ogg quicktime
        vnd.divx vnd.mpegurl vnd.rn-realvideo
        webm x-avi x-flv x-m4v x-matroska x-mpeg2
        x-ms-asf x-ms-wmv x-ms-wmx x-msvideo
        x-ogm x-ogm+ogg x-theora x-theora+ogg
      '';

    in
    {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.mpv ];
      xdg.mimeApps = lib.x.genMimes "mpv.desktop" (audioMimes ++ videoMimes);
    };
}
