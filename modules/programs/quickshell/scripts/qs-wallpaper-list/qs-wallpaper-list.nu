let thumb_dir = xdg-base-dir cache-file "rong"
let wallpaper_dir = $"(xdg-base-dir user-videos)/wallpapers"

let format = {|filename|
  let realpath = $filename | path expand
  let hash: string = $realpath | hash md5

  # requires rong --preview-format jpg
  let thumb = $"($thumb_dir)/($hash).jpg" | path expand
  let quantized = $"($thumb_dir)/($hash).json" | path expand

  if ($thumb | path exists) {
    let color = open $quantized | get celebi | transpose | rename color count | sort-by count -r | first | get color | default "#222222"
    return {
      filename: $realpath
      preview: $thumb
      color: $color
    }
  }
}

ls --all $wallpaper_dir
| where type == file
| sort-by modified --reverse
| get name
| par-each $format
| to json --raw
