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

- **aria2**: The fastest download manager.
- **btop**: The best process viewer.
- **buildix**: Build nixpkgs package.
- **compile-scss**: Compile scss files.
- **control**: Launch application with cpu and ram limit.
- **crop-image**: Crop image.
- **fastfetch**: Fast system information.
- **fd**: Fast find command.
- **ffchunk**: Split video into chunks.
- **ffcrop**: Crop video.
- **ffgif**: Convert video to gif.
- **ffscale**: Resize video.
- **ffstack**: Stack videos.
- **field**: `awk` like tool but only for fields.
- **fork**: Fork any process to background.
- **freeze**: Screenshot tool for cmdline.
- **fzf**: Interactive fuzzy finder.
- **gimme**: Nix shell wrapper.
- **git-copy**: Git clone wrapper which saves repos in
  `~/git/<username>/<reponame>`.
- **google-fonts**: Download google fonts.
- **hyprlock**: Hyprland's screen locker.
  - `hyprlock-player-info`: Helper script for hyprlock which displays player
    info.
  - `hyprlock-restore`: Helper script for hyprlock which restores hyprlock if it
    dies.
- **mpv**: The best media player.
- **mpvpaper-daemon**: `mpvpaper` contraller which auto plays-pauses based on
  hyprland window focusing.
- **neovim**: Text best editor. _I use neovim btw_
- **nix-update-file**: Update a file in which is not part of nixpkgs.
- `opustag-fix`: Don't use this!
- **organize-files**: Powerfull file organizer.
- `quickshell`: Not a flake output
  - `qs-coverdb`: Caches the current mpris cover art.
  - `qs-hyprshutdown`: Broken!
  - `qs-screenrecord`: Helper script for screenrecord.
    - `qs-ffmpeg-compress-progress`: Helper script for qs-screenrecord to show
      progress.
  - `qs-system-usage`: Helper script for system-usage.
  - `qs-tmux-session-info`: Helper script for tmux-session-info.
  - `qs-toggle`: Helper script for toggling quickshell values.
  - `qs-wallpaper-list`: Helper script for wallpaper-list in
    `XDG_VIDEOS_DIR/wallpapers`.
  - `qs-weather`: Helper script for weather.
- **ripgrep**: The grep in the town!
- **runix**: Run nix package without installing it.
- **simplify-names**: Remove non-alphanumeric characters from filenames.
- **snapshot-hyprland-clients**: Take screenshot of hyprland clients.
- **sync-nixpkgs-revision**: Sync nixpkgs revision to a file.
- **tealdeer**: Community maintained TLDR pages.
- **tldr**: Same output as tealdeer.
- **tmux**: The terminal multiplexer.
  - `tmux-sessionizer`: Create session by selection repos from `~/git`
    - `tmux-list-repos`: Smart repository finder which looks directory and
      sub-directory in `~/git`
    - `tmux-navigate`: Navigate between windows and panel with same keybind
      (`Alt+hjkl`).
- **wallpaper**: Sets wallpaper to geving path or random from
  `$XDG_VIDEOS_DIR/wallpapers`. Highly specific to this config and avoid general
  use!
- **wget**: The easier file downloader!
- **xdg-base-dir**: The crossplatform $XDG_BASE_DIRS finder.
- **yt-dlp**: The internet video downloader.
- **yt-dlm**: `yt-dlp` optimized for downloading audio.
