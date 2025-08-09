#!/bin/bash

set -e

cp "$HOSTS_RESTRICTED_FILE" "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.restricted"
echo_success "hosts.restricted updated successfully at ${FOCUSD_CONFIG_HOSTS_DIR}/hosts.restricted"

cp "$HOSTS_DEFAULT_FILE" "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.default"
echo_success "hosts.default updated successfully at ${FOCUSD_CONFIG_HOSTS_DIR}/hosts.default"

cp "$HOSTS_NO_SOCIAL_FILE" "${FOCUSD_CONFIG_HOSTS_DIR}/hosts.no_social"
echo_success "hosts.no_social updated successfully at ${FOCUSD_CONFIG_HOSTS_DIR}/hosts.no_social"