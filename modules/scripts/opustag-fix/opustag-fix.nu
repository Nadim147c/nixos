# Mutiple Aritst Music Fix
def main [
  ...paths: string # Input video file
] {
  let audios = fd '\.opus$' --type f ...$paths | lines | path expand | uniq | enumerate

  let total = $audios | length
  for file in $audios {
    let index = $file.index
    let audio = $file.item
    printf "\r[%d/%d]" ($index + 1) $total

    let artists = (
      opustags -z $audio
      | split row (char nul)
      | find --no-highlight --regex "ARTISTS=.*"
      | each {|it| $it | str replace "ARTISTS=" "" }
    )

    if ($artists | length) < 2 {
      continue
    }

    let joined = $artists | first
    let flags = (
      echo [ARTIST ARTISTSORT ALBUMARTIST ALBUMARTISTSORT]
      | each {|it| [--set $"($it)=($joined)"] }
      | flatten
    )

    printf "\r%s [%s]\n" $audio $joined

    opustags ...$flags -i $audio
  }
}
