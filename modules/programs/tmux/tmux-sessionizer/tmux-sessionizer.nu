# A smart tmux session manager for developers.
#
# Recursively discovers all Git repositories in ~/git, presents them in an interactive fuzzy finder,
# then creates or switches to a dedicated tmux session for the selected project.
#
# Each session is automatically configured with:
#   - A window running your preferred $EDITOR (default: nvim)
#   - A window with an empty shell for git commands, builds, or other tasks
#
# Session names are sanitized from repository paths (colons replaced with hyphens)
# to ensure tmux compatibility.
def main [] {
  let selected_repo = tmux-list-repos ~/git | fzf --ansi
  tmux-list-repos add (echo ~/git | path join $selected_repo | path expand)

  let fullpath = echo ~/git | path join $selected_repo | path expand
  let session_name = $selected_repo | str replace --all ":" "-"

  # Get tmus sessions names as a nushell list
  let sessions = tmux ls | lines | each {|it| $it | split row --number 2 : | first }

  if $session_name not-in $sessions {
    tmux new-session -d -s $session_name -c $fullpath ($env.EDITOR | default nvim)
    tmux new-window -t $session_name -c $fullpath
  }

  if ("TMUX" in $env) {
    tmux switch-client -t $session_name
  } else {
    tmux attach -t $session_name
  }
}
