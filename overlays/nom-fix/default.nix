inputs: final: prev: {
  nix-output-monitor = prev.nix-output-monitor.override {
    extraComposeFunctions = [
      (prev.haskell.lib.compose.appendPatch (
        prev.fetchpatch2 {
          url = "https://patch-diff.githubusercontent.com/raw/maralorn/nix-output-monitor/pull/321.patch";
          relative = "nix-output-monitor";
          hash = "sha256-OVem8p/Q2MAo+fZk2MmqO8cBANDFRJQdtpd6ypUIdP0=";
        }
      ))
    ];
  };

  nh = prev.nh.override {
    inherit (final) nix-output-monitor;
  };
}
