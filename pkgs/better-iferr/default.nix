{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "better-iferr";
  version = "0-unstable-2026-10-05";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Nadim147c";
    repo = "better-iferr";
    rev = "22660c6d8544f3dabc83c1a6dc32f5117e96a6ac";
    hash = "sha256-hGqo2arGlqK4pJGY8jtDSL4VViMsvqsDC2Gr/LJae1I=";
  };

  vendorHash = "sha256-jmcgzdAC/3qCBPvgh/UgILDNpugl1e4s7OwvA9cRdoc=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/Nadim147c/better-iferr";
    license = lib.licenses.gpl3Only;
    mainProgram = "better-iferr";
  };
})
