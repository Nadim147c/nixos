let wallpaper_dir: string = xdg-base-dir user-videos | path join "wallpapers"
let rong_cache: string = xdg-base-dir cache-file "rong"
let quickshell_cache: string = xdg-base-dir cache-file "quickshell" | path join "wallpapers"

let format = {|filename|
  let realpath = $filename | path expand
  let hash: string = $realpath | hash md5

  let cached_preview: string = $quickshell_cache | path join $"($hash).jpg" | path expand
  # requires rong --preview-format jpg
  let rong_preview = $rong_cache | path join $"($hash).jpg" | path expand
  let quantized = $rong_cache | path join $"($hash).json" | path expand

  let final_cached_preview = if ($cached_preview | path exists) {
    $cached_preview
  } else if ($rong_preview | path exists) {
    $rong_preview
  } else {
    null
  }

  if ($cached_preview == null) {
    return
  }

  let color = open $quantized | get celebi | transpose | rename color count | sort-by count -r | first | get color | default "#222222"
  return {
    filename: $realpath
    preview: $cached_preview
    color: $color
  }
}

ls --all $wallpaper_dir
| where type == file
| sort-by modified --reverse
| get name
| each $format
| to json --raw
