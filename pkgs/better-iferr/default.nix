{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "better-iferr";
  version = "0-unstable-2026-07-23";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Nadim147c";
    repo = "better-iferr";
    rev = "670d9a7757ef44312885ce038badad4764b243f0";
    hash = "sha256-1EjwdF8wAQa4GnUj1oEevryxiYFAF1GFXo34SNfbs+c=";
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
