{ self, inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages.kopuz = inputs.kopuz.packages.${system}.default;
      packages.nuke-kopuz = pkgs.writers.writeNuBin "nuke-kopuz" /* nu */ ''
        # Nuke kopuz library to force a library rescan.
        def main [] {
          let config = (
            $env.XDG_CONFIG_HOME?
            | default (echo ~/.config)
            | path join "kopuz"
          )
          let library = $config | path join library.json
          open $library
          | upsert tracks []
          | upsert albums []
          | collect
          | save -f $library
        }
      '';
    };
  flake.modules.nixos.gui =
    { pkgs, system, ... }:
    {
      packages = [
        inputs.kopuz.packages.${system}.default
        self.packages.${system}.nuke-kopuz
        pkgs.picard
        pkgs.nicotine-plus
      ];
    };
}
