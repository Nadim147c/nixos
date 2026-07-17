switch:
    nh os switch .

nixos:
    sudo nixos-rebuild switch --flake . -L

build:
    nh os build .

boot:
    nh os boot .

check:
    nix flake check

fmt:
    nix fmt

quickshell-dev:
    systemctl --user stop quickshell.service
    qs -p modules/programs/quickshell/shell.qml

update-discord-settings:
  go run ./modules/programs/discord/update.go > ./modules/programs/discord/_settings.nix
