{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "field";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "Nadim147c";
    repo = "field";
    rev = "v${version}";
    hash = "sha256-veYzUL27VIuY1bF9T0unwDTsVEDVMI6Cwp+dgYbjSA8=";
  };

  vendorHash = "sha256-UWScxgpNuf/duOBIAZUh9YeI6WTb0OfyyHS+1ERDsAY=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];
  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) /* bash */ ''
    installShellCompletion --cmd field \
        --bash <($out/bin/field _carapace bash) \
        --fish <($out/bin/field _carapace fish) \
        --zsh <($out/bin/field _carapace zsh)
  '';

  meta = {
    description = "A easy, elegant and flexible tool for accessing fields";
    homepage = "https://github.com/Nadim147c/field";
    license = lib.licenses.gpl3Only;
    mainProgram = "field";
  };
}
