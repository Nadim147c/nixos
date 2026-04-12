{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config) username;
  user = {
    owner = username;
    mode = "0600";
  };
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      copyPath = path: user // { inherit path; };
      createConfigKey = name: copyPath "${config.home.xdg.configHome}/${name}";
      createSSHKey = name: copyPath "${config.home.home.homeDirectory}/.ssh/${name}";
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [
        age
        sops
      ];

      fileSystems."/home".neededForBoot = true;

      sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        useSystemdActivation = true;
        age.keyFile = "${config.home.xdg.configHome}/sops/age/keys.txt";
        secrets = {
          password = { };
          "rclone/gdrive/id" = user;
          "rclone/gdrive/secret" = user;
          "rclone/crypt/pass" = user;
          "rclone/crypt/salt" = user;
          "weather_api" = createConfigKey "weather_api.key";
          "ssh/aur" = user;
          "ssh/github" = user;
          "ssh/gitlab" = user;
          "ssh/master" = createSSHKey "master";
        };
      };

      users.users.${username} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.password.path;
      };

      home.sops.secrets = config.sops.secrets;
    };

  # HACK: Currently the sops is imported as nixosModules.
  # This will not work on standalone home-manager. Currently.
  # I'm passing the nixos config as home-manager options so that
  # home-manager service can access the secrets paths.
  flake.modules.homeManager.base = {
    options.sops.secrets = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };

  };
}
