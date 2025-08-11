#!/bin/bash

set -e

# ----------------------------------------
# Create default hosts file for focus mode
# ----------------------------------------

if [ ! -f "$HOSTS_NO_SOCIAL_FILE" ]; then
    add_comment "Lightest hosts file for focus mode." "$HOSTS_NO_SOCIAL_FILE"

    add_hosts_base_or_backup_to_file "$HOSTS_NO_SOCIAL_FILE"

    add_domains_to_host "$HOSTS_NO_SOCIAL_FILE" "$DOMAINS_SOCIAL_MEDIA" "Blocked domains: Social media websites"

    add_domains_to_host "$HOSTS_NO_SOCIAL_FILE" "$DOMAINS_ADULTS" "Blocked domains: Adult content websites"
else
    echo_success "Found $HOSTS_NO_SOCIAL_FILE"
fi
