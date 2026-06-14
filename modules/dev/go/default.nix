{ lib, ... }:
{
  flake.modules.nixos.dev =
    { config, pkgs, ... }:
    let
      cfg = config.dev.go;
    in
    {
      options.dev.go.enable = lib.x.opt.bool true;

      config = lib.mkIf cfg.enable {
        packages = with pkgs; [
          go
          gotools
          gofumpt
          golangci-lint
          golangci-lint-langserver
          gopls
          revive
        ];

        sessionVariables =
          let
            data = config.home.xdg.data.directory;
            cache = config.home.xdg.cache.directory;
          in
          {
            GOMODCACHE = "${cache}/go/mod";
            GOBIN = "${data}/go/bin";
            GOPATH = "${data}/go";
            CGO_ENABLED = "0";
          };

        home.xdg.config.files."go/telemetry/mode".text = "off 2026-06-01";
      };
    };
}
