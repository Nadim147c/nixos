# Build a standalone Nix package file (not in nixpkgs or a flake).
def main [
  file: string # Nix file to build.
] {
  let fullpath = $file | path expand

  print $"Building ($fullpath)"

  echo $"
  let
    pkgs = import <nixpkgs> {};
  in {
    default = pkgs.callPackage ($fullpath) { };
  }
  " | save --raw --force /tmp/nix-build.nix

  nix-build /tmp/nix-build.nix -A default
}
