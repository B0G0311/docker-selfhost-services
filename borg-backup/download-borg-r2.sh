#!/bin/bash

# Set up environment variables
export BORG_REPO="your_borg_repo"
export BORG_PASSPHRASE="your_borg_passphrase"
export GOTIFY_TOKEN="your_gotify_token"
export GOTIFY_URL="your_gotify_url"

# Set up notification function
notify() {
    curl -X POST -H "Content-Type: application/json" \
    -d "{\"message\": \"$1\"}" \
    $GOTIFY_URL/message?token=$GOTIFY_TOKEN
}

# Step 1: Ask user to input the folder to download backup to
read -p "Enter the folder to download the backup to: " DOWNLOAD_FOLDER

# Step 2: Check available space on the host
FREE_SPACE=$(df -BG --output=avail / | sed '1d;s/[^0-9]//g')
REQUIRED_SPACE="10"  # Modify this value according to the space required by the selected backup

# Step 3: Print the free space on the host in GB
echo "Free space on host: $FREE_SPACE GB"

# Step 4: Give the user the option to choose available backups and required space
# Replace the placeholders with actual backup names and their required space
available_backups=("backup1" "backup2" "backup3")
required_space=("5" "3" "8")

echo "Available backups:"
for ((i=0; i<${#available_backups[@]}; i++)); do
    echo "$(($i+1)). ${available_backups[$i]} (${required_space[$i]} GB)"
done

read -p "Choose the backup number: " selected_backup_number

# Validate user input
if [[ ! $selected_backup_number =~ ^[1-${#available_backups[@]}]$ ]]; then
    echo "Invalid backup selection. Exiting..."
    exit 1
fi

selected_backup_index=$(($selected_backup_number-1))
selected_backup=${available_backups[$selected_backup_index]}
required_space=${required_space[$selected_backup_index]}

# Step 5: Download the remote encrypted backup the user selected
echo "Starting download of backup: $selected_backup"
echo "Required space: $required_space GB"

# Check if enough space is available on the host
if [[ $FREE_SPACE -lt $required_space ]]; then
    echo "Insufficient space on host. Exiting..."
    exit 1
fi

# Download the backup
borg extract $BORG_REPO::$selected_backup --destination $DOWNLOAD_FOLDER \
    2>&1 | tee /tmp/borg_download.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Download failed with error: $(tail -n1 /tmp/borg_download.log)"
    exit 1
fi

echo "Download completed successfully"

# Final notification
notify "Backup download process completed"
