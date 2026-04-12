{
  self,
  inputs,
  ...
}:
{

  perSystem =
    { pkgs, ... }:
    {
      packages.yankd-impure = inputs.wrappers.lib.wrapPackage (_: {
        inherit pkgs;
        package = pkgs.lib.flakePackage inputs.yankd;
        runShell = [
          /* bash */ ''
            local_override="$HOME/.local/bin/yankd"
            if [ -x "$local_override" ]; then
              exec -a "$0" "$local_override" "$@"
              exit
            fi
          ''
        ];
      });
    };

  flake.modules.homeManager.base = {
    imports = [ inputs.yankd.homeModules.yankd ];
  };

  flake.modules.homeManager.gui =
    { system, ... }:
    {
      services.yankd = {
        enable = true;
        package = self.packages.${system}.yankd-impure;
      };
    };
}
