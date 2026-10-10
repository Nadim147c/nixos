switch:
    nh os switch --accept-flake-config .

nixos:
    sudo nixos-rebuild switch --flake . -L --accept-flake-config

build:
    nh os build --accept-flake-config .

boot:
    nh os boot --accept-flake-config .

check:
    nix flake check

fmt:
    nix fmt

quickshell-dev:
    find ./modules -iname "*.frag" -print0 | \
      xargs -0 -P4 -I {} sh -c \
      'echo "Compiling $1..."; qsb --glsl "100 es,120,150" --hlsl 50 --msl 200 -o "$1.qsb" "$1"' _ {}
    quickshell-dev

update-flatpak:
   nu ./modules/features/flatpak/update.nu

update-discord-settings:
    jq . ~/.config/Equicord/settings/settings.json > ./modules/programs/discord/settings.json
