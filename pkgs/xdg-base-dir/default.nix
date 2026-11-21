{
  lib,
  stdenv,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "xdg-base-dir";
  version = "0-unstable-2026-09-15";
  __structuredAttrs = true;

  src = lib.cleanSource (
    lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./xdg-base-dir.go
        ./go.mod
        ./go.sum
      ];
    }
  );

  vendorHash = "sha256-q4/49uX1678cO8w5byAyDSNPNjbMa398+xMzeJynMCw=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd xdg-base-dir \
      --bash <($out/bin/xdg-base-dir _carapace bash) \
      --fish <($out/bin/xdg-base-dir _carapace fish) \
      --zsh <($out/bin/xdg-base-dir _carapace zsh)
  '';

  ldflags = [ "-s" ];

  meta.mainProgram = finalAttrs.pname;
})
