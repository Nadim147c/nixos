{ inputs, self, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages.neovim =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            topiary-nushell = inputs.topiary-nushell.packages.${system}.default;
          };
          modules = (inputs.import-tree ./_config).imports;
        }).neovim;
    };

  flake.modules.nixos.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) neovim;
    in
    {
      environment.sessionVariables.EDITOR = "nvim";
      environment.systemPackages = [ neovim ];
    };

  flake.modules.homeManager.base =
    { system, ... }:
    let
      inherit (self.packages.${system}) neovim;
    in
    {
      home.packages = [ neovim ];
    };
}
