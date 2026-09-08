def main [player: string] {
  let pid: int = (
    dbus-send
    --session
    --dest=org.freedesktop.DBus
    --type=method_call
    --print-reply /org/freedesktop/DBus
    org.freedesktop.DBus.GetConnectionUnixProcessID
    ("string:" + $player)
    | lines
    | last
    | split words
    | last
    | into int
  )

  hyprctl dispatch $"hl.dsp.focus\({ window = \"pid:($pid)\" }\)"
}
