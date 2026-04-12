_: {
  flake.modules.nixos.dev = {
    boot.binfmt.emulatedSystems = [
      "wasm32-wasi"
      "x86_64-windows"
      "aarch64-linux"
    ];
  };
}
