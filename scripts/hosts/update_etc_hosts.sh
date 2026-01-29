#!/bin/bash

set -e

# The hosts files are generated in the hosts/ directory and need to be copied to config directory

# Define source paths (where dynamic generator creates files)
LOCKED_SOURCE="${SCRIPT_DIR}/../hosts/hosts.locked"
UNLOCKED_SOURCE="${SCRIPT_DIR}/../hosts/hosts.unlocked"

# Copy locked profile (all blocks active)
if [ -f "$LOCKED_SOURCE" ]; then
    cp "$LOCKED_SOURCE" "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.locked"
    echo_success "hosts.locked updated successfully at ${FOCUSD_CONFIG_HOSTS_DIR}/hosts.locked"
else
    echo_warning "hosts.locked not found at $LOCKED_SOURCE"
fi

# Copy unlocked profile (only always-blocked)
if [ -f "$UNLOCKED_SOURCE" ]; then
    cp "$UNLOCKED_SOURCE" "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.unlocked"
    echo_success "hosts.unlocked updated successfully at ${FOCUSD_CONFIG_HOSTS_DIR}/hosts.unlocked"
else
    echo_warning "hosts.unlocked not found at $UNLOCKED_SOURCE"
fi

# Apply locked profile by default
if [ -f "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.locked" ]; then
    cp "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.locked" "/etc/hosts"
    echo_success "Applied locked profile to /etc/hosts by default"
fi