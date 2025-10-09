RG_NAME="rg-docker-app"
VAR1_NAME="PDI_ANSWER"
VAR2_NAME="POLL_URL"

VAR1_VALUE="PDI_answer70898341"
VAR2_VALUE="https://poll.fm/16117952"

for APP in $(az containerapp list -g $RG_NAME --query "[].name" -o tsv); do
  echo "Updating environment variables for $APP..."
  
  az containerapp update \
    -g $RG_NAME \
    -n $APP \
    --set-env-vars \
      $VAR1_NAME=$VAR1_VALUE \
      $VAR2_NAME=$VAR2_VALUE \
    --only-show-errors \
    -o none
  
  for REV in $(az containerapp revision list -g "$RG_NAME" -n "$APP" \
                 --query "[?properties.active==\`true\`].name" -o tsv); do
    az containerapp revision restart -g "$RG_NAME" -n "$APP" \
      --revision "$REV" # --only-show-errors -o none
  done

  echo "✅ $APP updated and restarted"
done
