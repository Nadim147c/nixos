let name: string = (date now | format date "%Y-%m-%d_%H:%M:%S")

let temp_file = $"/tmp/screenshot_($name).png"
let final_path = $"(xdg-base-dir user-picture)/screenshot/($name).png"

mkdir -v ($final_path | path dirname)

def main [] { main region }

def 'main region' [] {
  let colors = get_colors
  let region: string = (slurp -d -b $colors.background -c $colors.outline)

  print $"Captured a region ($region)"
  grim -g $region $temp_file

  open --raw $temp_file | wl-copy

  let action: string = (
    notify-send "Screenshot Captured" "Saved to clipboard"
    --expire-time="5000"
    --icon $temp_file
    --action="annotate=Annotate"
    --action="delete=Delete"
    | complete
    | get stdout
    | str trim
  )

  print $"Actions: ($action)"

  if ($action == "annotate") {
    satty --filename $temp_file --output-filename $final_path --early-exit --copy-command wl-copy
  } else if ($action == "delete") {
    rm -f $final_path
  } else {
    cp --verbose $temp_file $final_path
  }
  rm -f $temp_file
}

def 'main screen' [] {
  grim $temp_file

  open --raw $temp_file | wl-copy

  let action: string = (
    notify-send "Screenshot Captured" "Saved to clipboard"
    --expire-time="5000"
    --icon=$temp_file
    --action="annotate=Annotate"
    --action="delete=Delete"
    | complete
    | get stdout
    | str trim
  )

  print $"Actions: ($action)"

  if ($action == "annotate") {
    satty --filename $temp_file --output-filename $final_path --early-exit --copy-command wl-copy
  } else if ($action == "delete") {
    rm -f $final_path
  } else {
    cp --verbose $temp_file $final_path
  }
  rm -f $temp_file
}

def get_colors [] {
  try {
    let colors = open $"(systemd-path user-state-private)/rong/colors.json"
      | select material.background.hex_rgb material.outline.hex_rgb
      | rename background outline
      | upsert background {|it| $it.background + "88" } # semi transparent
    return $colors
  } catch {
    return {
      background: ("#222222" + "88") # semi transparent
      outline: "#111111"
    }
  }
}
