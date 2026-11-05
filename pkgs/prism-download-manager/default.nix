{
  lib,
  appimageTools,
  fetchurl,
  nix-update-script,
}:

let
  pname = "prism-download-manager";
  version = "1.2.4";
  src = fetchurl {
    url = "https://github.com/FortoGraphy/${pname}/releases/download/v${version}/Prism_${version}_amd64.AppImage";
    hash = "sha256-4l2Yz5/PE47oFt95gQT15FeBPOsanRBZwFF/DATriq8=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };

in
appimageTools.wrapType2 {
  inherit pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  extraPkgs =
    pkgs: with pkgs; [
      yt-dlp
      ffmpeg-headless
      deno
    ];

  extraInstallCommands = ''
    mv $out/bin/prism-download-manager $out/bin/prism
    install -m 444 -D ${appimageContents}/Prism.desktop $out/share/applications/Prism.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256@2/apps/prism.png $out/share/icons/hicolor/256x256/apps/prism.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The fast, beautiful, open-source download manager for Windows, macOS and Linux — up to 32 connections, browser integration, video & MP3 downloads, crash-safe resume";
    homepage = "https://github.com/FortoGraphy/prism-download-manager";
    changelog = "https://github.com/FortoGraphy/prism-download-manager/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Nadim147c ];
    mainProgram = "prism";
    platforms = [ "x86_64-linux" ];
  };
}
