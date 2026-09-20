def main [
  wallpaper?: string
  --color (-c): string
] {
  let wallpaper_dir: string = xdg-base-dir user-videos | path join "wallpapers"

  let input = if $wallpaper != null {
    $wallpaper
  } else {
    find_wallpaper $wallpaper_dir
  }

  print $"Setting wallpaper ($input)"

  # update the wallpapers timestamp (used for quickshell sorting)
  touch $input

  hyprctl cursorpos | split words | qs-wallpaper setCursor ...$in
  qs-wallpaper set $input

  if $color != null {
    rong video --source-color $color -v $input
  } else {
    rong video -v $input
  }
}

def find_wallpaper [wallpaper_dir: string] {
  let current = try { open ~/.local/state/quickshell/wallpaper.txt | str trim } catch { "" }
  mkdir $wallpaper_dir
  # This will error if no item is found
  fd '\.(mp4|mkv|webm|gif)$' $wallpaper_dir | lines | where ($it != $current) | shuffle | get 0
}
