def main [] {
  let quickshell_cache = echo ~/.cache/quickshell/wallpapers | path expand
  mkdir $quickshell_cache

  let wallpapers: string = xdg-base-dir user-videos | path join "wallpapers"
  let files = fd '\.(mp4|mkv|avi|mov|wmv|flv|webm|mpeg|mpg|3gp)$' $wallpapers | lines
  for file in $files {
    if ($"($quickshell_cache)/($file | hash md5).jpg" | path exists) {
      continue
    }

    let image = rong video --dry-run --template '{{.Image}}' $file

    let out = $image
      | path parse
      | upsert parent $quickshell_cache
      | upsert ext "jpg"
      | path join

    printf '%q -[120p]-> %q\n' $image $out
    magick $image -resize x120 $out
  }
}
