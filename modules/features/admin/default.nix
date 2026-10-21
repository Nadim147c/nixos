{ config, ... }:
{
  flake.tree.nixos.base.common =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        generateCompletions = false;
      };
      users = {
        groups.${config.username} = { };
        users.${config.username} = {
          shell = pkgs.fish;
          isNormalUser = true;
          description = config.fullname;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        };
      };
    };
}
