# Split media file into chunks
def main [
  input: string # Input video file to scale
  output?: string # Output video file
  --scale (-c): float # Scale multiplier (e.g. 2, 1.5, 0.5)
  --quality (-q): int # Target height (e.g. 1080, 720)
  --size (-s): string # Explicit scale string (e.g. 1920:1080)
  --filter (-f): string # Additional ffmpeg filter (e.g. fps=10)
] {
  let meta = get_duration $input

  let scale_filter = if ($size != null) {
    $size
  } else if ($quality != null) {
    let r = meta.height / $quality
    printf "%d:%d" (round_to_even (meta.width * r)) (round_to_even $quality)
  } else if ($scale != null) {
    printf "%d:%d" (round_to_even ($meta.width * $scale)) (round_to_even ($meta.height * $scale))
  } else {
    error make -u {msg: "No scale, size or quality specified"}
  }

  let final_filter = if ($filter != null) {
    printf "scale=%s,%s" $scale_filter $filter
  } else {
    "scale=" + $scale_filter
  }

  let output_name = if ($output != null) {
    $output
  } else {
    input
    | path expand
    | path parse
    | update stem { $in.stem + "_" + $scale_filter }
    | file
  }

  ffmpeg -i $input -vf $final_filter $output_name
}

def round_to_even [num] {
  ($num // 2) * 2
}

def get_duration [input: string] {
  try {
    ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of json $input
    | from json
    | get streams.0
    | select height width
  } catch {
    error make -u {msg: "Failed to get video metadata"}
  }
}
