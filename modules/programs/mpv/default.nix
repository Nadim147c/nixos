{
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib.attrsets) nameValuePair genAttrs';
  inherit (lib.lists) optional singleton;
  inherit (lib.strings) makeBinPath;
in
{
  perSystem =
    { pkgs, ... }:
    let
      createScripts = scripts: genAttrs' scripts (script: nameValuePair script.pname { path = script; });
      bin = singleton pkgs.yt-dlp;
      paths = makeBinPath bin;
    in
    {
      packages.mpv = inputs.wrappers.wrappers.mpv.wrap {
        inherit pkgs;
        package = pkgs.mpv;
        prefixVar = singleton [
          "PATH"
          ":"
          paths
        ];
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
          ytdl-raw-options=sub-lang="en,eng,enUS,en-US",yes-playlist=,concurrent-fragments=4
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
          -             add speed -0.1
          *             set speed 1
          +             add speed +0.1
          KP_DIVIDE     add speed -0.1
          KP_MULTIPLY   set speed 1
          KP_SUBTRACT   add speed +0.1
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
        # keep-sorted start
        "audio/3gpp"
        "audio/aac"
        "audio/aacp"
        "audio/ac3"
        "audio/alac"
        "audio/amr"
        "audio/amr-wb"
        "audio/eac3"
        "audio/flac"
        "audio/midi"
        "audio/mp3"
        "audio/mp4"
        "audio/mpeg"
        "audio/ogg"
        "audio/opus"
        "audio/true-hd"
        "audio/vnd.dts"
        "audio/vnd.dts.hd"
        "audio/vnd.wave"
        "audio/vorbis"
        "audio/wav"
        "audio/wave"
        "audio/webm"
        "audio/x-ape"
        "audio/x-matroska"
        "audio/x-ms-wma"
        "audio/x-wav"
        "audio/x-wavpack"
        # keep-sorted end

        # Video
        # keep-sorted start
        "video/3gpp"
        "video/3gpp2"
        "video/av1"
        "video/avi"
        "video/dv"
        "video/mj2"
        "video/mp2t"
        "video/mp4"
        "video/mpeg"
        "video/mpeg4"
        "video/ogg"
        "video/quicktime"
        "video/vnd.rn-realvideo"
        "video/webm"
        "video/x-f4v"
        "video/x-flv"
        "video/x-m4v"
        "video/x-matroska"
        "video/x-matroska-3d"
        "video/x-mpeg"
        "video/x-ms-asf"
        "video/x-ms-wmv"
        "video/x-msvideo"
        "video/x-ogm"
        "video/x-theora"
        # keep-sorted end
      ];
    };
}
