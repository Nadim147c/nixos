let format = "{{playerName}}»¦«{{title}}»¦«{{status}}»¦«{{xesam:url}}»¦«{{artist}}"
let update_status = {|it|
  match $it.status {
    Playing => 0
    Paused => 1
    Stopped => 2
    _ => 3
  }
}

let info = (
  playerctl --all-players metadata --format $format
  | lines
  | split column '»¦«' player title status url artist
  | upsert status $update_status
  | sort-by status
  | first
)

if $info == null { return }

let player = $info.player
let host = try { $info.url | url parse | get host } catch { "" }

let icon = match [$player $host] {
  [spotify _] => "󰓇"
  [YoutubeMusic _] => "󰗃"
  [tauon _] => "󰻂"
  [_ $host] if $host ends-with "youtube.com" => "󰗃"
  _ => ""
}

if $icon != "" {
  print $"($icon)  ($info.artist) - ($info.title)"
} else {
  print --stderr $"No icon found for ($info.player)"
  print $"($info.artist) - ($info.title)"
}
