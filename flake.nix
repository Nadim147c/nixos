{
  nixConfig = {
    eval-cache = true;
    experimental-features = [
      "nix-command"
      "cgroups"
      "flakes"
      "pipe-operators"
    ];
    trusted-users = [
      "root"
      "@build"
      "@wheel"
      "@admin"
    ];
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org"
      "https://nvf.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
    ];

    builders-use-substitutes = true;
    flake-registry = "";
    http-connections = 50;
    show-trace = true;
    use-cgroups = true;
    use-xdg-base-directories = true;
  };
  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
    discord-voice-rpc = {
      url = "https://flakehub.com/f/Nadim147c/discord-voice-rpc/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-bwrapper = {
      url = "https://flakehub.com/f/Naxdy/nix-bwrapper/1.*";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nuschtosSearch.follows = "";
      inputs.treefmt-nix.follows = "";
      inputs.sscli.follows = "";
    };
    hjem = {
      url = "https://flakehub.com/f/feel-co/hjem/0.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rong = {
      url = "https://flakehub.com/f/Nadim147c/rong/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "https://flakehub.com/f/Mic92/sops-nix/0.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    topiary-nushell = {
      url = "github:blindFS/topiary-nushell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tree-sitter-nu = {
      url = "github:nushell/tree-sitter-nu";
      flake = false;
    };
    treefmt-nix = {
      url = "https://flakehub.com/f/numtide/treefmt-nix/0.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yankd = {
      url = "github:Nadim147c/yankd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      # Put our custom lib function under lib.x
      specialArgs.lib = inputs.nixpkgs.lib.extend (
        final: prev: {
          inherit (inputs.home-manager.lib) hm;
          x = (import ./lib) final prev;
        }
      );
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } (inputs.import-tree ./modules);
}
