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
      createSSHKey = name: copyPath "${config.home.directory}/.ssh/${name}";
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
        age.keyFile = "${xdg.config.directory}/sops/age/keys.txt";
        secrets = {
          password = { };
          "rclone/gdrive/id" = user;
          "rclone/gdrive/secret" = user;
          "rclone/crypt/pass" = user;
          "rclone/crypt/salt" = user;
          "weather_api" = createConfigKey "weather_api.key";
          "ssh/aur" = createSSHKey "aur";
          "ssh/github" = createSSHKey "github";
          "ssh/gitlab" = createSSHKey "gitlab";
          "ssh/master" = createSSHKey "master";
        };
      };

      users.users.${username} = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.password.path;
      };
    };
}
