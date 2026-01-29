#!/bin/bash

set -e

# Creates a directory with 755 permissions and root ownership.
create_root_dir(){
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "Directory $dir already exists."
        return
    fi
    echo_info "Creating directory $dir with permissions 755."
    mkdir -m 755 -p "$dir"
    chown root:root "$dir"
    chmod 755 "$dir"
    echo_success "Directory $dir created successfully."
}

# Remove any existing Focusd configuration folder and recreate it.
rm -rf "$FOCUSD_CONFIG_DIR"
create_root_dir "$FOCUSD_CONFIG_DIR"

# Create the hosts profiles folder inside the configuration directory.
create_root_dir "$FOCUSD_CONFIG_HOSTS_DIR"