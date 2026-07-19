# Sync list of input git repository to one or many github
def main [
  config_file: string # Path to config.{json,yaml,yml,toml} file
] {
  let config = open $config_file # Nushell auto detect format from extension

  let cache = $env.XDG_CACHE_HOME? | default ~/.cache | path expand | path join git-sync
  mkdir $cache

  let total_sync = $config.sync | length

  $config.sync | enumerate | each {|it|
    let index = $it.index
    let name = $it.item.name
    let branch = $it.item.branch? | default "main"
    let input = $it.item.input

    let bold_underline = {attr: [b underline]}
    print --stderr $"(ansi cyan)[($index + 1)/($total_sync)](ansi reset) (ansi yellow_bold)Syncing ($name) (ansi $bold_underline)($input)(ansi reset)"

    let hash = $input | hash sha256 | decode hex | encode base64 --url
    let clone_path = $cache | path join $"($name)-($hash)"

    # Ensure we have a bare clone that only tracks the desired branch
    if not ($clone_path | path exists) {
      print --stderr $"(ansi green)  Cloning bare repository into ($clone_path)(ansi reset)"
      let clone = ^git clone --bare --single-branch --branch $branch $input $clone_path | complete
      if $clone.exit_code != 0 {
        print --stderr $"(ansi red)  ERROR: failed to clone ($input)(ansi reset)"
        return
      }
    } else {
      # Verify existing repository: is it a git repo and is the origin remote correct?
      let is_git = ^git -C $clone_path rev-parse --git-dir | complete | $in.exit_code == 0
      let origin_ok = ^git -C $clone_path remote get-url origin | complete | $in.exit_code == 0 and ($in.stdout | str trim) == $input

      if not $is_git or not $origin_ok {
        print --stderr $"(ansi yellow)  Repository invalid or origin changed, re-cloning(ansi reset)"
        rm -rf $clone_path
        let clone = ^git clone --bare --single-branch --branch $branch $input $clone_path | complete
        if $clone.exit_code != 0 {
          print --stderr $"(ansi red)  ERROR: failed to clone ($input)(ansi reset)"
          return
        }
      }
    }

    # Fetch latest changes for the branch (force update the local ref)
    print --stderr $"(ansi blue)  Fetching latest ($branch)(ansi reset)"
    let fetch = ^git -C $clone_path fetch origin $"+refs/heads/($branch):refs/heads/($branch)" --force | complete
    if $fetch.exit_code != 0 {
      print --stderr $"(ansi yellow)  WARNING: fetch failed, may not have latest changes(ansi reset)"
    }

    # Prepare output remotes
    let outputs = $it.item.output? | default {} | transpose | rename name url

    if ($outputs | is-empty) {
      print --stderr $"(ansi yellow)  WARN: No output remotes configured(ansi reset)"
      return
    }

    for output in $outputs {
      let remote_name = $output.name
      let remote_url = $output.url

      print --stderr $"(ansi magenta)  Pushing to ($remote_name) (ansi $bold_underline)($remote_url)(ansi reset)"
      # Add or update remote
      let has_remote = do -i { ^git -C $clone_path remote get-url $remote_name } | complete
      if $has_remote.exit_code == 0 {
        ^git -C $clone_path remote set-url $remote_name $remote_url
      } else {
        ^git -C $clone_path remote add $remote_name $remote_url
      }

      # Push the branch
      let push = ^git -C $clone_path push $remote_name $branch | complete

      if $push.exit_code != 0 {
        print --stderr $"(ansi red)  ERROR: pushing to ($remote_name):(ansi reset)"
        print --stderr $push.stderr
      } else {
        print --stderr $"(ansi green)  Pushed ($branch) to ($remote_name)(ansi reset)"
      }

      sleep 10sec
    }
  } | ignore
}
