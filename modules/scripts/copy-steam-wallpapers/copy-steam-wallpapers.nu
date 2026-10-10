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

    try {
      ln $it $out
      print (printf "linked %q -> %q\n" $it $out)
    } catch {
      cp -f $it $out
      print (printf "copied %q -> %q\n" $it $out)
    }
  }
  | ignore
}
