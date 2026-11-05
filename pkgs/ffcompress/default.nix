{
  lib,
  makeWrapper,
  ffmpeg-headless,
  buildGo127Module,
  fetchFromGitHub,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "ffcompress";
  version = "0-unstable-2026-11-06";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Nadim147c";
    repo = "ffcompress";
    rev = "9233bcd1d1c26369c4956b7764b4eab6ce8d4d94";
    hash = "sha256-3DBIU/P6Zd7m8A8xtXWHJdOQ5BMVkW0y+vpyxa9wbUo=";
  };

  vendorHash = "sha256-eS1g8zqdYmSXHsrlDo857rePYcaOMPKhhnifWaA1HE8=";

  ldflags = [ "-s" ];

  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/ffcompress \
      --suffix PATH : "${ffmpeg-headless}/bin"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Compress media files using ffmpeg with nice progress";
    homepage = "https://github.com/Nadim147c/ffcompress";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Nadim147c ];
    mainProgram = "ffcompress";
  };
})
