#!/bin/bash

RG_NAME="rg-docker-app"
VAR1_NAME="PDI_ANSWER"
VAR2_NAME="POLL_URL"

VAR1_VALUE="PDI_answer73632755"
VAR2_VALUE="https://poll.fm/16816575"

usage() {
  echo "Usage: $0 {on|off|run}"
  echo "  on   - Start all container apps"
  echo "  off  - Stop all container apps"
  echo "  run  - Update env vars and restart revisions"
  exit 1
}

cmd_on() {
  for APP in $(az containerapp list -g "$RG_NAME" --query "[].name" -o tsv); do
    echo "Starting $APP..."
    for REV in $(az containerapp revision list -g "$RG_NAME" -n "$APP" \
                   --query "[?properties.active==\`true\`].name" -o tsv); do
      az containerapp revision activate -g "$RG_NAME" -n "$APP" --revision "$REV" \
        --only-show-errors -o none
    done
    echo "✅ $APP started"
  done
}

cmd_off() {
  for APP in $(az containerapp list -g "$RG_NAME" --query "[].name" -o tsv); do
    echo "Stopping $APP..."
    for REV in $(az containerapp revision list -g "$RG_NAME" -n "$APP" \
                   --query "[?properties.active==\`true\`].name" -o tsv); do
      az containerapp revision deactivate -g "$RG_NAME" -n "$APP" --revision "$REV" \
        --only-show-errors -o none
    done
    echo "✅ $APP stopped"
  done
}

cmd_run() {
  for APP in $(az containerapp list -g "$RG_NAME" --query "[].name" -o tsv); do
    echo "Updating environment variables for $APP..."

    az containerapp update \
      -g "$RG_NAME" \
      -n "$APP" \
      --set-env-vars \
        "$VAR1_NAME=$VAR1_VALUE" \
        "$VAR2_NAME=$VAR2_VALUE" \
      --only-show-errors \
      -o none

    for REV in $(az containerapp revision list -g "$RG_NAME" -n "$APP" \
                   --query "[?properties.active==\`true\`].name" -o tsv); do
      az containerapp revision restart -g "$RG_NAME" -n "$APP" --revision "$REV" \
        --only-show-errors -o none
    done

    echo "✅ $APP updated and restarted"
  done
}

# --- Main ---
case "${1:-}" in
  on)  cmd_on  ;;
  off) cmd_off ;;
  run) cmd_run ;;
  *)   usage   ;;
esac