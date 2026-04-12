# Split media file into chunks
def main [
  ...files: string # video files
  --time (-t): duration = 20min # Length of each chunk
  --delete (-d) # delete original file after processing
] {
  if ($files | is-empty) {
    error make -u {msg: "Please prvide one or more input"}
  }

  for file in $files {
    let fullpath = ($file | path expand)

    if not ($fullpath | path exists) {
      error make -u {msg: $"File not found: ($file)"}
    }

    let ext = ($fullpath | path parse | get extension)
    if ($ext | is-empty) {
      error make -u {msg: $"File has no extension: ($file)"}
    }

    let stem = ($fullpath | path parse | get stem)
    let parent = ($fullpath | path parse | get parent)
    let output = ($parent | path join $"($stem).part%d.($ext)")

    print $"Processing \"($file)\""

    (
      ffmpeg -hide_banner
      -i $fullpath
      -f segment
      -c copy
      -segment_time ($time / 1sec | into float)
      -reset_timestamps 1
      -y $output
    )

    if $delete {
      rm $fullpath
    }
  }
}
