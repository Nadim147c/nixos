let name: string = (date now | format date "%Y-%m-%d_%H:%M:%S")

let description = get_description

let temp_file = $"/tmp/screenshot_($name).png"
let final_path = if ($description != "") {
  $"(xdg-base-dir user-picture)/screenshot/(similify_path_name $description)($name).png"
} else {
  $"(xdg-base-dir user-picture)/screenshot/($name).png"
}

let text_html = {
  tag: "img"
  attributes: {
    src: $final_path
    alt: $description
    time: (date now | format date "%d %B %Y")
  }
} | to xml

mkdir -v ($final_path | path dirname)

def main [] { main region }

def 'main region' [] {
  let colors = get_colors
  let region: string = (slurp -d -b $colors.background -c $colors.outline)

  print $"Captured a region ($region)"
  grim -g $region $temp_file

  yankd copy --data $"text/html=($text_html)" $temp_file

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

  yankd copy --data $"text/html=($text_html)" $temp_file

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

def similify_path_name [desc: string]: any -> string {
  echo $desc
  | str replace '~' $env.home
  | str replace --regex --all '[^A-Za-z0-9]+' '-'
  | str replace --regex --all '-+' '-'
  | str replace --regex --all '(^-+|-+$)' ''
  | str downcase
}

def get_description []: any -> string {
  let clients = hyprctl clients -j
    | from json
    | where focusHistoryID == 0
    | first
  if ($clients == null) {
    return ""
  }
  $clients | $"($in.class): ($in.title)"
}

def get_colors []: any -> record {
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
