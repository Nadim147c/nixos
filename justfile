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
    find ./modules -iname "*.frag" -exec sh -c \
      'echo "Compiling $1..."; qsb --glsl "100 es,120,150" --hlsl 50 --msl 200 -o "$1.qsb" "$1"' _ {} \;
    quickshell-dev

update-discord-settings:
    jq . ~/.config/Equicord/settings/settings.json > ./modules/programs/discord/settings.json
