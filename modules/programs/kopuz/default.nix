{
  inputs,
  self,
  ...
}:
{
  perSystem = { system, ... }: {
    packages.kopuz = (import inputs.kopuz { inherit system; }).kopuz;
  };

  flake.modules.nixos.gui = { pkgs, system, ... }: {
    packages = [
      self.packages.${system}.kopuz
      pkgs.picard
      pkgs.nicotine-plus
      pkgs.lrcget
    ];
  };
}
