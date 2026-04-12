#!/usr/bin/env bash

ACTION="${1:-shutdown}" # shutdown | reboot | logout
MAX_WAIT=7

close_all_clients() {
  hyprctl clients -j |
    jq -r '.[] | "address:\(.address)"' |
    xargs -r -n1 hyprctl dispatch closewindow || true
}

wait_until_no_clients() {
  for ((i = 1; i <= MAX_WAIT; i++)); do
    CLIENT_COUNT=$(hyprctl clients -j 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
    if [[ $CLIENT_COUNT -eq 0 ]]; then
      return 0
    fi

    # Attempt to close again in case some didn't close
    close_all_clients
    sleep 1
  done

  return 1
}

### MAIN ###
close_all_clients

echo "Waiting up to ${MAX_WAIT}s for windows to close..."
if wait_until_no_clients; then
  echo "All windows closed."
else
  notify-send "Hyprshutdown" "Timeout reached. Continuing..."
fi

case "$ACTION" in
shutdown)
  systemctl poweroff
  ;;
reboot)
  systemctl reboot
  ;;
logout)
  hyprctl dispatch exit
  ;;
*)
  echo "Unknown action: $ACTION"
  echo "Usage: hypr-power [shutdown|reboot|logout]"
  exit 1
  ;;
esac
