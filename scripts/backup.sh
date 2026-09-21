#!/bin/bash

DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="$HOME/kfi-hpc-lab/backups"
BACKUP_FILE="$BACKUP_DIR/kfi-hpc-backup-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

ssh ubuntu@hpc-controller \
"sudo tar -czf /tmp/kfi-hpc-backup.tar.gz \
/research \
/etc/slurm \
/etc/exports"

scp ubuntu@hpc-controller:/tmp/kfi-hpc-backup.tar.gz "$BACKUP_FILE"

ssh ubuntu@hpc-controller \
"sudo rm -f /tmp/kfi-hpc-backup.tar.gz"

echo "Backup completed:"
echo "$BACKUP_FILE"
