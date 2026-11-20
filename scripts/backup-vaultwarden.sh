#!/usr/bin/env bash
set -Eeuo pipefail

DATA_DIR="/opt/vaultwarden/data"
BACKUP_DIR="/opt/vaultwarden/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

WORK_DIR=$(mktemp -d "${BACKUP_DIR}/.vaultwarden-backup.XXXXXX")
ARCHIVE="${BACKUP_DIR}/vaultwarden-${TIMESTAMP}.tar.gz"

cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$WORK_DIR/data"
chmod 700 "$WORK_DIR"

echo "Starting Vaultwarden backup..."

# Create a consistent SQLite database backup.
sqlite3 "$DATA_DIR/db.sqlite3" \
    ".backup '${WORK_DIR}/data/db.sqlite3'"

# Preserve Vaultwarden's encryption key.
cp -a "$DATA_DIR/rsa_key.pem" "$WORK_DIR/data/"

# Preserve additional user data when present.
for item in attachments sends icon_cache config.json; do
    if [[ -e "$DATA_DIR/$item" ]]; then
        cp -a "$DATA_DIR/$item" "$WORK_DIR/data/"
    fi
done

# Create a compressed archive.
tar -czf "$ARCHIVE" -C "$WORK_DIR" data
chmod 600 "$ARCHIVE"

echo "Backup completed successfully."
echo "Archive: $ARCHIVE"
ls -lh "$ARCHIVE"

# Remove backup archives older than 24 hours.
find "$BACKUP_DIR" -maxdepth 1 -type f \
    -name 'vaultwarden-*.tar.gz' -mmin +1440 -delete

echo "Retention cleanup completed (24 hours)."
