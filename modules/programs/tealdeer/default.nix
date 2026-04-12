{ self, inputs, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.tldr = self'.packages.tealdeer;
      packages.tealdeer = inputs.wrappers.wrappers.tealdeer.wrap (_: {
        inherit pkgs;
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 100;
        };
      });
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.tealdeer ];
    };
}
