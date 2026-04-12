def main [] {
  let fmt = [
    "#{session_name}"
    "#{session_attached}"
    "#{session_windows}"
    "#{session_activity}"
  ] | str join "\t"

  ^tmux list-sessions -F $fmt
  | lines
  | where ($it | str trim) != ""
  | parse "{name}\t{active}\t{windows}\t{last_activity}"
  | update active {|it| $it.active | into int | $in > 0 }
  | update windows {|it| $it.windows | into int }
  | update last_activity {|it|
    $it.last_activity
    | into int
    | $in * 1000_000_000
    | into datetime
    | date humanize
    | str capitalize
  }
  | to json --raw
}
