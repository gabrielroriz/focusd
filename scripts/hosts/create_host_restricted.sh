#!/bin/bash

set -e

# -----------------------------------------------------------
# Create or update the restricted hosts file for focus mode
# -----------------------------------------------------------

remove_file "$HOSTS_RESTRICTED_FILE"

add_comment "This hosts file enforces full network restrictions for focus mode." "$HOSTS_RESTRICTED_FILE"

add_hosts_base_to_file "$HOSTS_RESTRICTED_FILE"

add_domains_to_host "$HOSTS_RESTRICTED_FILE" "$DOMAINS_DOPAMINE" "Blocked domains: Dopamine-related websites"

add_domains_to_host "$HOSTS_RESTRICTED_FILE" "$DOMAINS_ADULTS" "Blocked domains: Adult content websites"
