#!/usr/bin/env bash

quickshell_id=""
function qs-ipc() {
  if [[ -z $quickshell_id ]]; then
    quickshell_id=$(qs list --all --json | jq .[0].id -r | head -n1)
  fi
  gum log --prefix=Quickshell "$*"
  qs ipc -i "$quickshell_id" "$@"
}

function qs-status() {
  qs-ipc call recording setStatus "$1"
}
function qs-pid() {
  qs-ipc call recording setPID "$1"
}
function qs-perc() {
  qs-ipc call recording setPerc "$1"
}

function cleanup() {
  qs-status disabled
  qs-pid "do not kill me"
  qs-perc 0
}
trap cleanup EXIT

qs-status selecting

declare slurp_args=()
# shellcheck disable=SC1091
if source "${XDG_STATE_HOME:-$HOME/.local/state}/rong/colors.bash"; then
  slurp_args=(-b "${BACKGROUND}88" -c "$OUTLINE")
fi

pkill slurp || true

selection=$(slurp -d "${slurp_args[@]}")

output_dir="$(systemd-path user-videos)/recordings"
mkdir -p "$output_dir"

name=$(date +"%Y-%m-%d_%H:%M:%S")
output="${output_dir}/${name}.mp4"

gum log --prefix="Output" "$output"

qs-status recording
wf-recorder -y -g "$selection" -c libx264rgb -p crf=20 -p preset=veryfast --file="$output" >/dev/null 2>/dev/null &
rec_pid=$!
qs-pid "$rec_pid"

wait "$rec_pid"

qs-status disabled

answer=$(notify-send -u normal -a "Recorder" -A yes="Compress for web" -A no="Keep original" \
  "Recording finished" "Do you want to compress the video?")

if [[ $answer == "yes" ]]; then
  qs-status compressing
  web_output="${output%.mp4}_web.mp4"

  qs-ffmpeg-compress-progress "$output" "$web_output" | while IFS=$'\n' read -r perc; do
    qs-perc "$perc"
  done

  notify-send -u low -a "Recorder" "Compression done" "$web_output"
else
  notify-send -u low -a "Recorder" "Recording saved" "$output"
fi
