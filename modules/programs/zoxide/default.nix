{ lib, ... }:
let
  inherit (lib) toList getExe;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    let
      init = "${getExe pkgs.zoxide} init --cmd=cd";
      nushellSource = pkgs.runCommand "zoxide.nu" { } ''
        ${init} nushell | sed 's|"/homeless-shelter|$"($env.HOME)|g' > "$out"
      '';
    in
    {
      packages = toList pkgs.zoxide;
      programs = {
        bash.interactiveShellInit = ''
          source <(${init} bash)
        '';

        zsh.interactiveShellInit = ''
          source <(${init} zsh)
        '';

        fish.interactiveShellInit = ''
          ${init} fish | source
        '';

        nushell.interactiveShellInit = ''
          source ${nushellSource}
        '';
      };
    };
}
