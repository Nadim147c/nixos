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
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      inherit (config.home) xdg;
      copyPath = path: user // { inherit path; };
      createConfigKey = name: copyPath "${xdg.config.directory}/${name}";
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
        age.keyFile = "/var/sops/age.txt";
        secrets = {
          password = { };
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
        initialPassword = "letgo";
        #hashedPasswordFile = config.sops.secrets.password.path;
      };
    };
}
