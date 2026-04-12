# Crop video by detecting black bars or using a specified ratio.
def main [
  input: path # Path to input video
  output?: path # Path to output video (optional)
  --white # Auto detect white bar instead of black to crop
  --ratio (-r): string # Use a ratio instead of auto detect to crop. (ex: 1/2, 18x9, 16:9)
  --top: int # Number of pixel to add to the top after calculating the crop
  --bottom: int # Number of pixel to add to the bottom after calculating the crop
  --right: int # Number of pixel to add to the right after calculating the crop
  --left: int # Number of pixel to add to the left after calculating the crop
  --around: int # Number of pixel to add to the around after calculating the crop
  --threads: int = 4 # Number of threads to use when transcoding.
  --detection-time (-t): string = "2" # Number of seconds to detect the video for crop.
  --preview # Show a preview of the crop instead of outputting it
  --debug # Prints the debug info
] {
  $env.GUM_LOG_LEVEL = if $debug { "debug" } else { "info" }

  if ($ratio != null) and ($white or $detection_time != "2") {
    error make -u {msg: "--ratio cannot be used with --white or --detection-time"}
  }

  # Check input file exists
  if not ($input | path exists) {
    error make -u {msg: $"Provided path does not exist: ($input)"}
  }

  ^gum log --structured --level info "Input video path" path $input

  ^gum log --structured --level debug "Running ffprobe to get video dimensions"
  let ffprobe_output = ^ffprobe -v error -select_streams v:0 -show_entries format=duration -show_entries stream=width,height -of json $input | complete
  if $ffprobe_output.exit_code != 0 {
    error make -u {msg: "ffprobe failed"}
  }
  let ffprobe_json = $ffprobe_output.stdout | from json
  let streams = $ffprobe_json.streams
  if ($streams | length) == 0 {
    error make -u {msg: "Failed to find any video stream on input path"}
  }
  let videoWidth = $streams.0.width
  let videoHeight = $streams.0.height
  ^gum log --structured --level debug "Video dimensions" width $videoWidth height $videoHeight

  # --- Helper functions for crop adjustments ---
  def add-left [crop: record amount: int] {
    let max_shift = $crop.x
    let amt = if $crop.x - $amount < 0 { $crop.x } else { $amount }
    ^gum log --structured --level debug "Adjusting left" original_x $crop.x amount $amount new_x ($crop.x - $amt) new_width ($crop.w + $amt)
    $crop | update x ($crop.x - $amt) | update w ($crop.w + $amt)
  }
  def add-right [crop: record amount: int] {
    let max_w = $videoWidth - $crop.x
    let amt = if $crop.w + $amount > $max_w { $max_w - $crop.w } else { $amount }
    ^gum log --structured --level debug "Adjusting right" original_width $crop.w amount $amount new_width ($crop.w + $amt)
    $crop | update w ($crop.w + $amt)
  }
  def add-top [crop: record amount: int] {
    let max_shift = $crop.y
    let amt = if $crop.y - $amount < 0 { $crop.y } else { $amount }
    ^gum log --structured --level debug "Adjusting top" original_y $crop.y amount $amount new_y ($crop.y - $amt) new_height ($crop.h + $amt)
    $crop | update y ($crop.y - $amt) | update h ($crop.h + $amt)
  }
  def add-bottom [crop: record amount: int] {
    let max_h = $videoHeight - $crop.y
    let amt = if $crop.h + $amount > $max_h { $max_h - $crop.h } else { $amount }
    ^gum log --structured --level debug "Adjusting bottom" original_height $crop.h amount $amount new_height ($crop.h + $amt)
    $crop | update h ($crop.h + $amt)
  }

  # --- Determine crop parameters ---
  let base_crop = if $ratio != null {
    ^gum log --structured --level info "Using ratio-based crop" ratio $ratio
    # Ratio‑based crop
    mut parts = $ratio | split row '/|x|:' | each { into float }

    if ($parts | length) == 1 { $parts = $parts | append 1 }

    if ($parts | length) != 2 {
      error make -u {msg: "Invalid ratio format. Use e.g., 16/9, 16:9, 18*9"}
    }

    let cropWidth = $parts.0
    let cropHeight = $parts.1

    let rw = $videoWidth / $cropWidth
    let rh = $videoHeight / $cropHeight
    let ratio_val = if $rw < $rh { $rw } else { $rh }

    let newWidth = ($ratio_val * $cropWidth | math round)
    let newHeight = ($ratio_val * $cropHeight | math round)

    let x = (($videoWidth - $newWidth) / 2 | math round)
    let y = (($videoHeight - $newHeight) / 2 | math round)

    {w: $newWidth h: $newHeight x: $x y: $y}
  } else {
    ^gum log --structured --level info "Auto-detecting crop using ffmpeg cropdetect" detection_time $detection_time white_mode $white
    # Auto‑detect using cropdetect
    let filter = if $white {
      "eq=contrast=1.8,negate,cropdetect"
    } else {
      "eq=contrast=1.8,cropdetect"
    }

    # Run ffmpeg detection and capture combined output
    let detection_result = ^ffmpeg -i $input -t $detection_time -vf $filter -f null - | complete
    if $detection_result.exit_code != 0 {
      error make -u {msg: "ffmpeg crop detection failed"}
    }

    # Find the last line containing 'crop='
    let line = (
      $detection_result.stderr
      | rg -o `crop=((\d+:){3}\d+)`
      | lines
      | uniq -c
      | sort-by count
      | last
      | get value --optional
      | default null
    )
    if $line == null {
      error make -u {msg: "Could not detect crop from video"}
    }
    ^gum log --structured --level debug "Detection lines" lines ($detection_result.stderr | rg -o `crop=((\d+:){3}\d+)`)

    # Extract crop=w:h:x:y
    let p = ($line | parse 'crop={w}:{h}:{x}:{y}' | first)
    {
      w: ($p.w | into int)
      h: ($p.h | into int)
      x: ($p.x | into int)
      y: ($p.y | into int)
    }
  }

  ^gum log --structured --level debug "Base crop (before padding)" crop ($base_crop | to yaml)

  mut final_crop = $base_crop
  if $top != null { $final_crop = add-top $final_crop $top }
  if $bottom != null { $final_crop = add-bottom $final_crop $bottom }
  if $left != null { $final_crop = add-left $final_crop $left }
  if $right != null { $final_crop = add-right $final_crop $right }
  if $around != null {
    ^gum log --structured --level debug "Applying around padding" around $around
    $final_crop = add-top $final_crop $around
    $final_crop = add-bottom $final_crop $around
    $final_crop = add-left $final_crop $around
    $final_crop = add-right $final_crop $around
  }

  ^gum log --structured --level debug "Crop after padding" crop ($final_crop | to yaml)

  # Round to even numbers (required by some codecs)
  $final_crop = (
    $final_crop
    | update w (round_to_even $final_crop.w)
    | update h (round_to_even $final_crop.h)
    | update x (round_to_even $final_crop.x)
    | update y (round_to_even $final_crop.y)
  )

  ^gum log --structured --level debug "Final crop after rounding to even" crop ($final_crop | to yaml)

  let output_path = if $output == null {
    let parts = $input | path parse
    let new_stem = $"($parts.stem)($final_crop.w)x($final_crop.h)"
    $parts | upsert stem $new_stem | path join
  } else { $output }

  ^gum log --structured --level info "Output path" path $output_path

  if $preview {
    ^gum log --structured --level info "Showing preview"
    # Scale preview to reasonable size (max dimension ~500px)
    let max_dim = if $final_crop.w > $final_crop.h { $final_crop.w } else { $final_crop.h }
    let preview_ratio = $max_dim / 500.0
    let scale_w = ($final_crop.w / $preview_ratio | math round)
    let scale_h = ($final_crop.h / $preview_ratio | math round)
    let filter = $"crop=($final_crop.w):($final_crop.h):($final_crop.x):($final_crop.y),scale=($scale_w):($scale_h)"
    ^gum log --structured --level debug "Preview filter" filter $filter
    ^ffplay -i $input -hide_banner -vf $filter e+o>| ignore
  } else {
    ^gum log --structured --level info "Starting encoding" threads $threads
    let filter = $"crop=($final_crop.w):($final_crop.h):($final_crop.x):($final_crop.y)"
    ^gum log --structured --level debug "Encoding filter" filter $filter
    (
      gum spin --title "Cropping video..." --
      ffmpeg -i $input -threads $threads -vf $filter $output_path
    )
  }
}

def round_to_even [x] {
  $x | into int | $in // 2 | $in * 2
}
