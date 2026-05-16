switch:
    nh os switch .

nixos:
    sudo nixos-rebuild switch --flake .

build:
    nh os build .

check:
    nix flake check

fmt:
    nix fmt


quickshell-dev:
  systemctl --user stop quickshell.service
  qs -p modules/programs/quickshell/shell.qml

