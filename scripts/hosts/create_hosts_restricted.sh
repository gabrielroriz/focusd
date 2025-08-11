#!/bin/bash

set -e

# ------------------------------------------------
# Create the restricted hosts file for focus mode
# ------------------------------------------------

if [ ! -f "$HOSTS_RESTRICTED_FILE" ]; then
    add_comment "This hosts file enforces full network restrictions for focus mode." "$HOSTS_RESTRICTED_FILE"

    add_hosts_base_or_backup_to_file "$HOSTS_RESTRICTED_FILE"

    add_domains_to_host "$HOSTS_RESTRICTED_FILE" "$DOMAINS_DOPAMINE" "Blocked domains: Dopamine-related websites"

    add_domains_to_host "$HOSTS_RESTRICTED_FILE" "$DOMAINS_ADULTS" "Blocked domains: Adult content websites"
else
    echo_success "Found $HOSTS_RESTRICTED_FILE"
fi