# qs-coverdb downloads and caches cover.
def main [cover_url?: string] {
  if $cover_url == null { return }

  let parsed_url = $cover_url | url parse

  if $parsed_url.scheme == "file" { return $parsed_url.path }

  let ext = try { $cover_url | rg -o --color=never `\.\w+$` } catch { ".png" }

  let cache_dir = systemd-path cache-file "mpris" "covers"
  mkdir $cache_dir

  let cache_file = $cache_dir | path join $"($cover_url | hash md5)($ext)"

  if not ($cache_file | path exists) {
    http get --redirect-mode follow $cover_url | save $cache_file
  }

  $cache_file
}
