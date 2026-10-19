{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "qml-language-server";
  version = "0-unstable-2026-09-15";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "soramanew";
    repo = "qml-language-server";
    rev = "a23e1aa3cd6004dcec872f2e29f170639029db6e";
    hash = "sha256-7LbpnGyNAJch/WbSOuWfNU/ByaEv8GQifwlMCyO6p+Y=";
  };

  vendorHash = "sha256-J+0kFTKgluf+mabJepW+MGXUdHqYLFaUVAZEWcyHmyk=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "";
    homepage = "https://github.com/soramanew/qml-language-server";
    changelog = "https://github.com/soramanew/qml-language-server/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "qml-language-server";
  };
})
