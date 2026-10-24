# Copy video wallpaper from steam workshop directory
def main [
  --steam: string = ~/.local/share/Steam # Steam directory
  output: string # Output directory
] {
  let steam_dir = $steam | path join steamapps/workshop/content/431960 | path expand
  fd '\.(mp4|mkv|avi|mov|wmv|flv|webm|mpeg|mpg|3gp)$' $steam_dir --full-path --color=never
  | lines
  | each {|it|
    let out = $it
      | path parse
      | upsert stem {|it|
        $"($it.stem) - ($it.parent | path basename)"
      }
      | upsert parent $output
      | path join

    if ($out | path exists) {
      let in_inode = stat -c "%i" $it
      let out_inode = stat -c "%i" $out
      if $in_inode == $out_inode {
        print $"(print_path $it) and (print_path $out) are the same file!"
        return
      }
    }

    try {
      ln $it $out
      print $"linked (print_path $it) -> (print_path $out)."
    } catch {
      cp -f $it $out
      print $"copied (print_path $it) -> (print_path $out)."
    }
  }
  | ignore
}

def print_path [path: string]: nothing -> string {
  printf "%s%q%s" (ansi green3b) $path (ansi reset)
}
