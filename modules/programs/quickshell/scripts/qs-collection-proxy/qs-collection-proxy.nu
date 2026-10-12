def main [...inputs: string] {
  let portal_dir: string = $env.HOME | path join ".portal"

  for file in $inputs {
    if ($file | str starts-with $portal_dir) {
      print $"($file)\t($file)"
      return
    }

    if (($file | path type) != "file") {
      return
    }

    let id: string = xxhsum $file | split words | first

    let proxy: string = $file
      | path parse
      | upsert parent {|it|
        let path = $portal_dir | path join $id
        mkdir $path
        return $path
      }
      | path join

    if not ($proxy | path exists) {
      try {
        ln $file $proxy
      } catch {
        ^cp --reflink=auto $file $proxy
      }
    }

    print $"($file)\t($proxy)"
  }
}
