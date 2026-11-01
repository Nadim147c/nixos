{
  flake.tree.nixos.dev.go =
    { config, pkgs, ... }:
    {
      packages = with pkgs; [
        go_1_27
        gotools
        gofumpt
        golangci-lint
      ];

      sessionVariables =
        let
          data = config.hj.xdg.data.directory;
          cache = config.hj.xdg.cache.directory;
        in
        {
          GOMODCACHE = "${cache}/go/mod";
          GOBIN = "${data}/go/bin";
          GOPATH = "${data}/go";
          PATH = [ "${data}/go/bin" ];
          CGO_ENABLED = "0";
        };

      hj.xdg.config.files."go/telemetry/mode".text = "off 2026-06-01";
    };
}
