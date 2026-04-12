# Stack multiple videos together!
def main [
  --horizontal (-h) # Use horizontal stack
  --vertical (-v) # Use vertical stack
  --extension (-e): string = "mp4" # The output extension
  --margin (-s): int = 0 # The spacing between videos
  --debug # Enable debug logging
  ...inputs: string
] {
  # Set log level based on --debug flag
  $env.GUM_LOG_LEVEL = if $debug { "debug" } else { "info" }

  if ($inputs | length) < 2 {
    error make -u {msg: "Insufficient amount of inputs!"}
  }

  if $horizontal and $vertical {
    error make -u {msg: "-h, --horizontal and -v, --vertical are mutually exclusive!"}
  }

  let size = (
    $inputs
    | each {|it| ffprobe -v quiet -print_format json -show_entries stream=width,height $it | from json | get streams }
    | flatten
    | where {|it| ("width" in $it and "height" in $it) }
  )

  let n = $inputs | length
  let list = get_list $n

  const extra_filter = "scale=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p"

  let filter_complex = if $horizontal {
    let min = $size | get height | math min

    let spacer = if $margin != 0 { $"color=c=black:size=($margin)x($min):d=1[spacer]" } else { "" }
    let count = if $margin != 0 { ($n * 2) - 1 } else { $n }
    let joiner = if $margin != 0 { "[spacer]" } else { "" }

    gum log --structured --level debug "Spacer filter" filter $spacer

    let resize = $list | each {|it| $"[($it):v]scale=-2:($min)[o($it)]" }
    let vstack = (
      $list
      | each {|it| $"[o($it)]" }
      | str join $joiner
      | $"($in)hstack=inputs=($count),($extra_filter)[out]"
    )
    [...$resize $spacer $vstack] | where ($it != "") | str join ";"
  } else {
    # Vertical stacking – adapted from horizontal logic
    let min = $size | get width | math min

    let spacer = if $margin != 0 { $"color=c=black:size=($min)x($margin):d=1[spacer]" } else { "" }
    let count = if $margin != 0 { ($n * 2) - 1 } else { $n }
    let joiner = if $margin != 0 { "[spacer]" } else { "" }

    gum log --structured --level debug "Spacer filter" filter $spacer

    let resize = $list | each {|it| $"[($it):v]scale=($min):-2[o($it)]" }
    let vstack = (
      $list
      | each {|it| $"[o($it)]" }
      | str join $joiner
      | $"($in)vstack=inputs=($count),($extra_filter)[out]"
    )
    [...$resize $spacer $vstack] | where ($it != "") | str join ";"
  }

  gum log --structured --level debug filter_complex $filter_complex

  let output = (
    $inputs
    | each {|it| $it | path parse | get stem }
    | str join "-"
    | str downcase
    | split words
    | str join "-"
    | $"($in).($extension)"
  )

  gum log --structured --level info "Generated video file" output $output

  (
    gum spin --title="Stacking videos..." --
    ffmpeg ...($inputs | each {|it| [-i $it] } | flatten)
    -filter_complex $filter_complex
    -map "[out]" -map 0:a?
    -map_metadata -1
    -c:v libx264 -crf 23 -preset veryfast -y
    $output
  )
}

def get_list [n: int] { ..($n - 1) }
