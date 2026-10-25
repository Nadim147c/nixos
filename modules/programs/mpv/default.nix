{
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib.attrsets) nameValuePair genAttrs';
  inherit (lib.lists) optional singleton;
in
{
  perSystem =
    { pkgs, ... }:
    let
      createScripts = scripts: genAttrs' scripts (script: nameValuePair script.pname { path = script; });
    in
    {
      packages.mpv = inputs.wrappers.wrappers.mpv.wrap {
        inherit pkgs;
        package = pkgs.mpv;
        script = createScripts (
          (with pkgs.mpvScripts; [
            modernx
            quality-menu
            sponsorblock
            thumbfast
            cut
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
          alang=en,eng,enUS,en-US
          user-agent=Mozilla/5.0

          # script-opts and ytdl-raw-options require specific formatting
          script-opts=ytdl_hook-ytdl_path=yt-dlp
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
          n             cycle-values af "lavfi=[dynaudnorm=f=75:g=25:p=0.55]" "lavfi=[dynaudnorm=f=50:g=31:p=0.95:m=10.0]" ""
        '';
      };
    };

  flake.tree.nixos.gui.mpv =
    { pkgs, ... }:
    {
      packages = singleton self.packages.${pkgs.stdenv.hostPlatform.system}.mpv;
      hj.xdg.mime-apps = lib.x.genMimes "mpv.desktop" [
        # Audio
        "audio/mpeg"
        "audio/mp3"
        "audio/mp4"
        "audio/aac"
        "audio/aacp"
        "audio/ogg"
        "audio/opus"
        "audio/vorbis"
        "audio/flac"
        "audio/wav"
        "audio/x-wav"
        "audio/wave"
        "audio/vnd.wave"
        "audio/webm"
        "audio/3gpp"
        "audio/amr"
        "audio/amr-wb"
        "audio/ac3"
        "audio/eac3"
        "audio/vnd.dts"
        "audio/vnd.dts.hd"
        "audio/true-hd"
        "audio/alac"
        "audio/x-ms-wma"
        "audio/x-ape"
        "audio/x-wavpack"
        "audio/midi"
        "audio/x-matroska"

        # Video
        "video/mp4"
        "video/mpeg"
        "video/ogg"
        "video/webm"
        "video/x-matroska"
        "video/quicktime"
        "video/x-msvideo"
        "video/avi"
        "video/x-ms-wmv"
        "video/x-flv"
        "video/3gpp"
        "video/3gpp2"
        "video/mp2t"
        "video/x-m4v"
        "video/x-ms-asf"
        "video/vnd.rn-realvideo"
        "video/x-ogm"
        "video/x-theora"
        "video/mj2"
        "video/dv"
        "video/x-f4v"
        "video/x-mpeg"
        "video/mpeg4"
        "video/av1"
        "video/x-matroska-3d"
      ];
    };
}
