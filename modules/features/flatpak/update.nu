let programs = [
  [name url "x86_64-linux" "aarch64-linux"];
  ["sonora" "https://github.com/sonorahq/sonora" `sonora-v.+-x86_64.flatpak` `sonora-v.+-aarch64.flatpak`]
  ["photocraft" "https://github.com/storytold/photocraft" `photocraft-.+-linux-x86_64.flatpak` `photocraft-.+-linux-aarch64.flatpak`]
  ["effectcraft" "https://github.com/storytold/effectcraft" `effectcraft-.+-linux-x86_64.flatpak` `effectcraft-.+-linux-aarch64.flatpak`]
]

let arches = ["x86_64-linux" "aarch64-linux"]

let result = $programs | reduce -f {} {|row acc|
    let parsed = $row.url | parse "https://github.com/{owner}/{repo}" | get 0
    let api = $"https://api.github.com/repos/($parsed.owner)/($parsed.repo)/releases/latest"
    let release = http get -H [User-Agent "nushell"] $api

    let per_arch = $arches | reduce -f {} {|arch m|
        let pattern = $row | get $arch
        if $pattern == "" {
          return $m
        }
        let asset = $release.assets | where  name =~ $pattern | first
        let sha = $asset.digest | split words | last | decode hex | encode base64

        $m | insert $arch {
          url: $asset.browser_download_url
          sha256: $"sha256-($sha)"
        }
      }

    $acc | insert $row.name $per_arch
  }

$result | save --force ./modules/features/flatpak/apps.json
