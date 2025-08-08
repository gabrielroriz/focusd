#!/bin/bash

set -e

# ----------------------------------------
# Create default hosts file for focus mode
# ----------------------------------------

if [ ! -f "$HOSTS_DEFAULT_FILE" ]; then
    add_comment "Lightest hosts file for focus mode." "$HOSTS_DEFAULT_FILE"

    add_hosts_base_to_file "$HOSTS_DEFAULT_FILE"

    add_domains_to_host "$HOSTS_DEFAULT_FILE" "$DOMAINS_ADULTS" "Blocked domains: Adult content websites"

    add_domains_to_host "$HOSTS_DEFAULT_FILE" "$DOMAINS_SOCIAL_MEDIA" "Blocked domains: Social media websites"
else
    echo_success "Found $HOSTS_DEFAULT_FILE"
fi
