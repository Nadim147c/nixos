# Split media file into chunks
def main [
  ...files: string # video files
] {
  let image_dir = xdg-base-dir user-pictures
  let video_dir = xdg-base-dir user-videos
  let audio_dir = xdg-base-dir user-music
  let document_dir = xdg-base-dir user-documents
  let apk_dir = $document_dir | path join "../apks" | path expand
  let script_dir = $document_dir | path join "../scripts" | path expand
  let binary_dir = $document_dir | path join "../bins" | path expand
  let archive_dir = $document_dir | path join "../archives" | path expand
  let torrent_dir = $document_dir | path join "../torrents" | path expand

  mkdir $image_dir $video_dir $audio_dir $document_dir $apk_dir $script_dir $binary_dir $archive_dir

  fd --type file . ...$files | lines | each {|it|
    let new_path = $it
      | path parse
      | upsert stem {|i|
        $i.stem
        | str replace --all --regex '[^A-Za-z0-9]' '-'
        | str replace --all --regex '-+' '-'
        | str trim --char "-"
      }
      | each {|i|
        let magic = magika --json $it | from json | get result | first

        let ext = if $magic.status == "ok" {
          $magic | get value.output.extensions | first
        } else { $i.extension }

        let group = if $magic.status == "ok" {
          $magic | get value.output.group
        }

        let parent = match [$ext $group] {
          [_ image] => $image_dir
          [_ audio] => $audio_dir
          [_ video] => $video_dir
          [_ code] => $script_dir
          [_ archive] => $archive_dir
          [apk executable] => $apk_dir
          [_ executable] => $binary_dir
          [torrent _] => $torrent_dir
          _ => { error make -u {msg: $"Unknown filetype group=($group) ext=($ext)"} }
        }

        $i | update parent $parent | update extension $ext
      }
      | path join

    if $it != $new_path {
      printf "%q -> %q\n" $it $new_path
      mv --progress $it $new_path
    }
  } | ignore
}
