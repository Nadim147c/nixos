def main [input: string output: string] {
  let duration = (
    ffprobe -v error
    -show_entries format=duration
    -of default=noprint_wrappers=1:nokey=1
    $input | into float
  )

  (
    ffmpeg -y -i $input
    -c:v libx264 -pix_fmt yuv420p -crf 28 -preset slow
    -nostats -progress pipe:1 $output
    e+o>| lines
    | where $it =~ 'out_time_us=\d+'
    | each {|it|
      let perc = $it | split row '=' | last | into float | $in / (1_000_000 * $duration)
      print $perc
    }
    | ignore
  )
}
