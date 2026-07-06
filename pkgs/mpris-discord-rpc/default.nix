{
  lib,
  ffmpeg,
  makeWrapper,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "mpris-discord-rpc";
  version = "0-unstable-2026-07-07";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Nadim147c";
    repo = "mpris-discord-rpc";
    rev = "6db780d33af6ed5d648996f8508ff7bc3af2a1f5";
    hash = "sha256-ewjdInFeLBg1fL58PCVI8AsBjxXrP/Rn5NKADetGvvY=";
  };

  vendorHash = "sha256-meRntBMBywbECVZjAn57FZTvY12QYtvdlQebgXLEuWo=";

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ ffmpeg ];

  postInstall = ''
    wrapProgram $out/bin/${finalAttrs.pname} \
        --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "";
    homepage = "https://github.com/Nadim147c/mpris-discord-rpc";
    mainProgram = "mpris-discord-rpc";
  };
})
