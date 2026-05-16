# NixOS

My new NixOS configuration using dendritic pattern.

## Installation

First, ensure you have `direnv` installed and allowed to load the environment:

```bash
nix-shell -p direnv
direnv allow # loads the NIX_CONFIG env
```

Apply the system configuration:

```bash
sudo nixos-rebuild switch --flake .
```

Or run any program directly from the flake, for example:

```bash
nix run .#neovim
```

## Programs

You can run any of the following programs directly via `nix run .#<name>` (e.g.,
`nix run .#neovim`):

- `aria2`
- `btop`
- `buildix`
- `compile-scss`
- `control`
- `crop-image`
- `electroharmonix`
- `fastfetch`
- `fd`
- `ffchunk`
- `ffcrop`
- `ffgif`
- `ffscale`
- `ffstack`
- `field`
- `fork`
- `freeze`
- `fzf`
- `gimme`
- `git-copy`
- `google-fonts`
- `hyprlock`
  - `hyprlock-player-info`
  - `hyprlock-restore`
- `mpv`
- `mpvpaper-daemon`
- `neovim`
- `nix-update-file`
- `opustag-fix`
- `organize-files`
- `quickshell`
  - `qs-coverdb`
  - `qs-ffmpeg-compress-progress`
  - `qs-hyprshutdown`
  - `qs-screenrecord`
  - `qs-system-usage`
  - `qs-tmux-session-info`
  - `qs-toggle`
  - `qs-wallpaper-list`
  - `qs-weather`
- `qt-m3shapes`
- `ripgrep`
- `rong-impure`
- `runix`
- `simplify-names`
- `snapshot-hyprland-clients`
- `sync-nixpkgs-revision`
- `tealdeer`
- `tldr`
- `tmux`
  - `tmux-sessionizer`
    - `tmux-list-repos`
    - `tmux-navigate`
- `wallpaper`
- `wget`
- `xdg-base-dir`
- `yt-dlm`
- `yt-dlp`
