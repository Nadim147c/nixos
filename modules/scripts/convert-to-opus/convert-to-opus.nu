# Convert audio files to Opus format and remove originals
#
# This command recursively finds all audio files in the specified directories,
# converts them to the Opus format (256kbps VBR, maximum compression) using ffmpeg,
# and deletes the original files after successful conversion.
#
# The conversion preserves no metadata from the original files.
# File identification is done using magika to ensure only actual audio files are processed.
# Processing happens in parallel for performance.
def main [...dirs: string] {
  let audios = fd --type file . ...$dirs | lines | each {|it|
      let res = magika --json $it | from json | first | get result
      if ($res.status == "ok") and ($res.value.output.group == "audio" or $res.value.output.group == "video") { $it }
    }

  let size = $audios | length
  $audios | enumerate | par-each {|audio|
    let input = $audio.item
    let index = $audio.index

    print $"[($index + 1)/($size)] ($input)"

    let opus = $input | path parse | update extension "opus" | path join
    ffmpeg -i $input -loglevel error -map_metadata -1 -y -c:a libopus -b:a 256k -vbr on -compression_level 10 $opus
    rm --verbose --force $input
  } | ignore
}
