{
  config,
  inputs,
  ...
}:
{
  flake.modules.nixos = {
    base =
      { pkgs, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          (inputs.nixpkgs.lib.mkAliasOptionModule [ "home" ] [ "home-manager" "users" config.username ])
        ];

        environment.systemPackages = [ pkgs.home-manager ];

        home-manager = {
          useUserPackages = true;
          backupFileExtension = "home.bak";
          users.${config.username}.imports = [
            (cfg: {
              home = {
                stateVersion = cfg.osConfig.system.stateVersion;
                homeDirectory = "/home/${config.username}";
              };
            })
            config.flake.modules.homeManager.base
          ];
        };
      };

    pc.home.imports = [
      config.flake.modules.homeManager.gui
      config.flake.modules.homeManager.dev
    ];

    dev.home.imports = [ config.flake.modules.homeManager.dev ];
    wireless.home.imports = [ config.flake.modules.homeManager.wireless ];
  };
}
