#!/bin/bash

# Set up environment variables
export DOCKER_REPO="/path/to/docker-selfhost-services"
export BORG_REPO="/borg"
export BORG_PASSPHRASE="borg_passphrase"
export CLOUDFLARE_R2_ACCOUNT_ID="your_account_id"
export CLOUDFLARE_R2_ZONE_ID="your_zone_id"
export CLOUDFLARE_R2_BUCKET_NAME="your_bucket_name"
export GOTIFY_TOKEN="your_gotify_token"
export GOTIFY_URL="your_gotify_url"

# Set up notification function
notify() {
    curl -X POST -H "Content-Type: application/json" \
    -d "{\"message\": \"$1\"}" \
    $GOTIFY_URL/message?token=$GOTIFY_TOKEN
}

EXCLUDES_FILE=$(dirname $0)/excludes.txt

# Step 1: Stop all running docker containers to ensure uncorrupted files
echo -e "\n** Stopping docker containers... **"
docker stop $(docker ps -q)

# Step 2: Create local borg backup
echo "Starting backup"
borg create --compression lzma,6 \
    --exclude-from ${EXCLUDES_FILE} \
    $BORG_REPO::$(date +%Y-%m-%d-%H-%M-%S) \
    $DOCKER_REPO \
    2>&1 | tee /tmp/borg.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    notify "Backup failed with error: $(tail -n1 /tmp/borg.log)"
    exit 1
fi
echo "Backup completed successfully"

# Step 3: Prune old backups (keep the most up-to-date daily, weekly, and monthly backups)
echo "Pruning old backups"
borg prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6 $BORG_REPO \
    2>&1 | tee /tmp/borg.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Pruning failed with error: $(tail -n1 /tmp/borg.log)"
    exit 1
fi
notify "Pruning completed successfully"

# Step 4: Synchronize the local backup to the R2 bucket using rclone
echo "Starting sync to R2 bucket"
rclone sync $BORG_REPO cloudflare_r2:$CLOUDFLARE_R2_BUCKET_NAME \
    --transfers 4 \
    --retries 5 \
    --config /root/.config/rclone/rclone.conf \ #Replace /root/ 
    --log-file /tmp/rclone.log
if [ $? -ne 0 ]; then
    echo "Sync failed with error: $(tail -n1 /tmp/rclone.log)"
    exit 1
fi
echo "Sync completed successfully"

# Step 5: Start all docker containers
echo -e "/n** Restarting docker containers... **"
docker start $(docker ps -a -q)

# Final notification
notify "Backup and sync process completed"
