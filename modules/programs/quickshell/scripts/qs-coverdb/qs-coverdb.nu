# qs-coverdb downloads and caches cover.
def main [cover_url?: string] {
  if $cover_url == null { return }

  let colors: string = xdg-base-dir state-file "rong" "state.json"
    | open $in
    | get quantized.wu
    | str join ","

  qs-stylize-cover --quality 500 --colors $colors --max-colors 0 $cover_url
}
