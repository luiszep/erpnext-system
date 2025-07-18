#!/bin/bash

S3_BUCKET="erpnext-backups-agora"

# Manually list the sites you want to back up
SITES=("testbusiness.agoraerp.com" "jtp.agoraerp.com")

for SITE in "${SITES[@]}"; do
  echo "🔄 Running backup for $SITE..."
  docker compose -p erpnext-one exec backend bench --site "$SITE" backup --with-files --verbose

  # Find the latest database backup file
  LATEST_FILE=$(docker compose -p erpnext-one exec --no-TTY backend sh -c "ls -t /home/frappe/frappe-bench/sites/$SITE/private/backups | grep database.sql.gz | head -n 1" 2>/dev/null | tr -d '\r\n')

  echo "🧪 Detected latest backup file: '$LATEST_FILE'"

  if [[ -z "$LATEST_FILE" ]]; then
    echo "❌ Could not determine latest backup file for $SITE. Skipping."
    continue
  fi

  echo "📦 Copying $LATEST_FILE from container to host..."
  docker cp erpnext-one-backend-1:/home/frappe/frappe-bench/sites/$SITE/private/backups/$LATEST_FILE .

  echo "☁️ Uploading $LATEST_FILE to S3 bucket $S3_BUCKET..."
  aws s3 cp "$LATEST_FILE" s3://$S3_BUCKET/backups/

  echo "🧹 Cleaning up local copy..."
  rm "$LATEST_FILE"

  echo "✅ Backup complete for $SITE"
  echo "----------------------------"
done

echo "🎉 All selected site backups uploaded to S3."
