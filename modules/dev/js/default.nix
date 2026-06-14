{
  flake.modules.nixos.dev =
    { config, pkgs, ... }:
    {
      sessionVariables = {
        NPM_CONFIG_USERCONFIG = pkgs.writeText "npm-config" /* ini */ ''
          min-release-age=7
        '';
        PNPM_HOME = "${config.home.xdg.data.directory}/pnpm";
      };
    };
}
