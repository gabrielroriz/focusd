#!/bin/bash

set -e

rm -rf "$FOCUSD_CONFIG_DIR"

mkdir -m 700 -p "$FOCUSD_CONFIG_DIR"
chown root:root "$FOCUSD_CONFIG_DIR"

if [ ! -f "$FOCUSD_CONFIG_FILE" ]; then
    echo "Creating default configuration file at $FOCUSD_CONFIG_FILE"
    echo "# Focusd Configuration File" > "$FOCUSD_CONFIG_FILE"
    echo_success "Default configuration file created successfully ($FOCUSD_CONFIG_FILE)."
fi

# https://chatgpt.com/c/6895d5af-8ae8-832c-a30e-efd4680a6a9f