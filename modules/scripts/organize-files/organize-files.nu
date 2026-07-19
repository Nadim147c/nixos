# Split media file into chunks
def main [
  ...files: string # video files
] {
  let image_dir = xdg-base-dir user-picture
  let gif_dir = $image_dir | path join "gif"
  let video_dir = xdg-base-dir user-videos
  let audio_dir = xdg-base-dir user-music
  let document_dir = xdg-base-dir user-documents
  let apk_dir = $document_dir | path join "../apks" | path expand
  let script_dir = $document_dir | path join "../scripts" | path expand
  let binary_dir = $document_dir | path join "../bins" | path expand
  let archive_dir = $document_dir | path join "../archives" | path expand
  let torrent_dir = $document_dir | path join "../torrents" | path expand

  mkdir $image_dir $gif_dir $video_dir $audio_dir $document_dir $apk_dir $script_dir $binary_dir $archive_dir $torrent_dir

  let files = fd --type file . ...$files | lines | collect
  let total = $files | length
  $files | enumerate | each {|x|
    let old_path = $x.item
    let new_path = $old_path
      | path parse
      | upsert stem {|i|
        $i.stem
        | str replace --all --regex '[^A-Za-z0-9]' '-'
        | str replace --all --regex '-+' '-'
        | str trim --char "-"
      }
      | each {|i|
        let magic = magika --json $old_path | from json | get result | first

        let ext = if $magic.status == "ok" {
          $magic | get value.output.extensions | first
        } else { $i.extension }

        let group = if $magic.status == "ok" {
          $magic | get value.output.group
        }

        let parent = match [$ext $group] {
          [gif image] => $gif_dir
          [_ image] => $image_dir
          [_ audio] => $audio_dir
          [_ video] => $video_dir
          [_ code] => $script_dir
          [_ archive] => $archive_dir
          [_ document] => $document_dir
          [_ text] => $document_dir
          [apk executable] => $apk_dir
          [_ executable] => $binary_dir
          [torrent _] => $torrent_dir
          _ => { error make -u {msg: $"Unknown filetype group=($group) ext=($ext)"} }
        }

        $i | update parent $parent | update extension $ext
      }
      | path join

    if $old_path != $new_path {
      printf "[%d/%d] %q -> %q\n" ($x.index + 1) $total $old_path $new_path
      mv --progress $old_path $new_path
    }
  } | ignore
}
