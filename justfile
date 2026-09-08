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
    find ./modules -iname "*.frag" -exec qsb --glsl "100 es,120,150" --hlsl 50 --msl 200 -o {}.qsb {} \;
    quickshell-dev

update-discord-settings:
    go run ./modules/programs/discord/update.go > ./modules/programs/discord/_settings.nix
