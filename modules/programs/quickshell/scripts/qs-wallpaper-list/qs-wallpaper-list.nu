let thumb_dir = xdg-base-dir cache-file "rong"
let wallpaper_dir = $"(xdg-base-dir user-videos)/wallpapers"

let format = {|filename|
  let realpath = $filename | path expand
  let hash = $realpath | hash md5

  # requires rong --preview-format jpg
  let thumb = $"($thumb_dir)/($hash).jpg" | path expand

  if ($thumb | path exists) {
    return {filename: $realpath preview: $thumb}
  }
}

ls --all $wallpaper_dir
| where type == file
| sort-by modified --reverse
| get name
| each $format
| to json --raw
