{
  config,
  inputs,
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
  perSystem = { pkgs, ... }: {
    packages.sops = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.sops;
      env.SOPS_AGE_KEY_FILE = "/nix/persist/var/lib/sops/age.txt";
    };
  };
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      copyPath = path: user // { inherit path; };
      createConfigKey = name: copyPath "${config.hj.xdg.config.directory}/${name}";
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [
        age
        sops
      ];

      sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        useSystemdActivation = true;
        age.keyFile = "/nix/persist/var/lib/sops/age.txt";
        secrets = {
          password = {
            neededForUsers = true;
          };
          slskd = { };
          "discord_client_id" = user;
          "freeimage_api" = user;
          "rclone/crypt/pass" = user;
          "rclone/crypt/salt" = user;
          "rclone/gdrive/id" = user;
          "rclone/gdrive/secret" = user;
          "ssh/aur" = user;
          "ssh/codeberg" = user;
          "ssh/github" = user;
          "ssh/gitlab" = user;
          "ssh/master" = user;
          "weather_api" = createConfigKey "weather_api.key";
          "acoustid_api" = createConfigKey "acoustid_api.key";
        };
      };

      users.users.${username} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.password.path;
      };
    };
}
