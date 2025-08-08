#!/bin/bash

set -e

cp "$HOSTS_RESTRICTED_FILE" "/etc/hosts.restricted"
cp "$HOSTS_DEFAULT_FILE" "/etc/hosts.default"
cp "$HOSTS_NO_SOCIAL_FILE" "/etc/hosts.no_social"