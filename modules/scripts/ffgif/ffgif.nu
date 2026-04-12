# Convert input video to gif using palette for better quality
def main [
  input: string # Input video file
  output?: string # Output gif name
] {
  let out_name = if ($output == null) {
    get_gif_name $input
  } else {
    $output
  }

  (
    ffmpeg -y -i $input -filter_complex "
        [0:v]split[v0][v1];
        [v0]palettegen[palette];
        [v1]fps=10[og];
        [og][palette]paletteuse
        " $out_name
  )
}

def get_gif_name [input: string] {
  $input | path parse | $"($in.parent | path expand)/($in.stem).gif"
}
