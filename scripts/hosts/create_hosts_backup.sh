
#!/bin/bash

set -e

# --------------------------------------------------------
# Create backup hosts with the current /etc/hosts content
# --------------------------------------------------------

if [ ! -f "$HOSTS_BACKUP_FILE" ]; then
  echo_info "Backup file not found: $HOSTS_BACKUP_FILE"
  cp "/etc/hosts" "$HOSTS_BACKUP_FILE"
  echo_success "Created backup file: $HOSTS_BACKUP_FILE"
else
  echo_success "Backup file found: $HOSTS_BACKUP_FILE"
fi