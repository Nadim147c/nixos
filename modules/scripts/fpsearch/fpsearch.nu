# Generate a acoustid fingerprint and search it with acoustid api
def main [
  input: string # Input video file
] {
  let fp = fpcalc -json $input | from json
  print --stderr $"(ansi blue)Fingerprint(ansi reset): ($fp.fingerprint)"

  let params = {
    client: (open --raw ~/.config/acoustid_api.key | str trim)
    format: "json"
    duration: ($fp.duration | into int)
    fingerprint: $fp.fingerprint
  }

  let url = echo https://api.acoustid.org/v2/lookup
    | url parse
    | upsert params $params
    | url join

  http get $url | to json
}
