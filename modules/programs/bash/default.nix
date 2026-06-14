{ ... }:
{
  flake.modules.nixos.base = {
    programs.bash.enable = true;
  };
}
