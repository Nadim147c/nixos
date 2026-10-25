# Clone a git repository via jj (default) or git.
#
# Resolves common hosts (GitHub, GitLab, Codeberg, Gist, AUR,
# self-hosted GitLab) to their SSH clone URIs, and defaults the
# destination to ~/git/<user>/<repo>. Extra arguments are
# forwarded to `jj git clone` (or `git clone --recursive`).
@example "Clone a GitHub repo (uses jj)" { git copy https://github.com/nushell/nushell } --result "Clones git@github.com:nushell/nushell into ~/git/nushell/nushell"
@example "Clone with plain git instead of jj" { git copy https://github.com/nushell/nushell --git } --result "Clones git@github.com:nushell/nushell via git clone --recursive"
@example "Clone into a custom directory" { git copy https://github.com/nushell/nushell -d /tmp/nu } --result "Clones git@github.com:nushell/nushell into /tmp/nu"
@example "Forward extra clone flags to jj/git" { git copy https://github.com/nushell/nushell --bare } --result "Clones a bare copy of git@github.com:nushell/nushell"
@example "Clone an AUR package" { git copy https://aur.archlinux.org/nushell-git.git } --result "Clones ssh://aur@aur.archlinux.org/nushell-git.git into ~/git/aur/nushell-git"
@example "Clone a gist" { git copy https://gist.github.com/alice/abc123 } --result "Clones git@gist.github.com:abc123 into ~/git/alice/abc123"
def main [
  remote_url: string # Repository URL (http or https)
  ...extra: string # Extra args forwarded to jj/git clone
  --destination (-d): string # Destination directory (default: ~/git/<user>/<repo>)
  --git (-g) # Use `git clone --recursive` instead of `jj git clone`
] {
  let parsed = $remote_url | str replace --regex '^gh:' "https://github.com/" | url parse

  if $parsed.scheme != "https" and $parsed.scheme != "http" {
    error make {msg: "URL must be http or https"}
  }

  let host = $parsed.host
  let pathstr: string = $parsed.path | str replace --regex '^/' ''

  # Resolve (uri, dir) based on host.
  let result: oneof<record<uri: string, dir: string>, error> = match $host {
    "gist.github.com" => {
      let gist_id = ($pathstr | split row "/" | first)
      {uri: $"git@($host):($gist_id)" dir: $pathstr}
    }
    "github.com" | "gitlab.com" | "codeberg.org" => {
      let clean = ($pathstr | split row "/" | take 2 | str join "/")
      {uri: $"git@($host):($clean)" dir: $clean}
    }
    "aur.archlinux.org" => {
      let clean = ($pathstr | str replace --regex '\.git$' '')
      let pkg = ($clean | path basename)
      {uri: $"ssh://aur@($host)/($pkg).git" dir: $"aur/($pkg)"}
    }
    $it if $it =~ '^gitlab\..*' => {
      let clean = ($pathstr | split row "/" | take 2 | str join "/")
      {uri: $"git@($host):($clean)" dir: $clean}
    }
    $it if ($pathstr | split row "/" | length) == 2 => {
      {uri: $remote_url dir: $pathstr}
    }
    _ => {
      error make --unspanned {msg: "Unsupported url host. Use git clone instead"}
    }
  }

  let clone_uri: string = $result.uri
  let clone_dir: string = $result.dir

  let target_dir: string = if ($destination | is-not-empty) {
    $destination
  } else {
    let username: string = ^gh auth status --active --jq '.[][][].login' --json hosts | complete | get stdout | str trim
    let adjusted = if $username != "" and ($clone_dir | str starts-with $"($username)/") {
      $clone_dir | str substring (($username | str length) + 1)..
    } else {
      $clone_dir
    }
    $env.XDG_PROJECTS_DIR? | default ~/git | path join $adjusted | path expand
  }

  if $git {
    ^git clone --recursive $clone_uri $target_dir ...$extra
  } else {
    ^jj git clone $clone_uri $target_dir ...$extra
  }
}
