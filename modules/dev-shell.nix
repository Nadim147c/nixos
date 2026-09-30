{ lib, ... }:
let
  inherit (lib.meta) getExe;
in
{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos";
        nativeBuildInputs = builtins.attrValues {
          inherit (pkgs)
            lua-language-server
            nh
            nix-fast-build
            nixd
            nixfmt
            stylua
            statix
            fortune
            pkg-config
            ;
          inherit (pkgs.qt6) qtshadertools;
          inherit (self'.packages) nu-formatter;
          quickshell-dev = pkgs.writeShellScriptBin "quickshell-dev" ''
            systemctl --user stop quickshell.service
            trap 'systemctl --user restart quickshell.service' EXIT
            ${getExe self'.packages.quickshell} -p modules/programs/quickshell/shell.qml
          '';
          quickshell-debug = pkgs.writeShellScriptBin "quickshell-debug" ''
            systemctl --user stop quickshell.service
            trap 'systemctl --user restart quickshell.service' EXIT
            ${getExe self'.packages.quickshell} --debug=6767 --waitfordebug -p modules/programs/quickshell/shell.qml
          '';
        };
        buildInputs = with pkgs; [
          nim
          procps
          pkg-config
        ];
      };
    };
}
