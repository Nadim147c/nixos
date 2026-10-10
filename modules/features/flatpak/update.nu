let programs = {
  sonora: "https://github.com/sonorahq/sonora"
}

let result = (
  $programs | transpose name url | reduce -f {} {|row acc|
    let parsed = ($row.url | parse "https://github.com/{owner}/{repo}" | get 0)
    let api = $"https://api.github.com/repos/($parsed.owner)/($parsed.repo)/releases/latest"
    let release = (http get -H [User-Agent "nushell"] $api)
    let asset = ($release.assets | where name =~ '\.flatpak$' | first)
    let file_url = $asset.browser_download_url
    let sha = $asset.digest | split words | last | decode hex | encode base64

    $acc | insert $row.name {
      url: $file_url
      sha256: $"sha256-($sha)"
    }
  }
)

$result | save --force ./modules/features/flatpak/apps.json
