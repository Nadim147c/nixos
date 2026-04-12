{ lib, ... }:
{
  flake.modules = {
    nixos.base =
      { config, ... }:
      {
        options.dev.go.enable = lib.x.opt.bool false;
        config.home.dev.go.enable = config.dev.go.enable;
      };

    nixos.dev.dev.go.enable = true;
    homeManager.dev.dev.go.enable = true;

    homeManager.base =
      { config, pkgs, ... }:
      {
        options.dev.go.enable = lib.x.opt.bool false;

        config = lib.mkIf config.dev.go.enable {
          home.packages = with pkgs; [
            gofumpt
            golangci-lint
            golangci-lint-langserver
            gopls
            revive
          ];
          home.sessionVariables = {
            GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
            GOBIN = "${config.xdg.dataHome}/go/bin";
            GOPATH = "${config.xdg.dataHome}/go";
            CGO_ENABLED = "0";
          };
          programs.go = {
            enable = true;
            telemetry.mode = "off";
            env = {
              GOPATH = "${config.xdg.dataHome}/go";
              GOBIN = "${config.xdg.dataHome}/go/bin";
            };
          };
        };
      };
  };
}
