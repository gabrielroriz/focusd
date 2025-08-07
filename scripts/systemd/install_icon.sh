#!/bin/bash

set -e

# ------------------------------------------------------------------------------
# Install focusd icon into hicolor icon theme
# ------------------------------------------------------------------------------

# Create target directory if it doesn't exist
if [ ! -d "$ICON_TARGET_DIR" ]; then
    sudo mkdir -p "$ICON_TARGET_DIR"
fi

# Copy the icon to the hicolor theme directory
sudo cp "$ICON_SOURCE" "$ICON_TARGET_PATH"

# Update icon cache
if icon_cache_output=$(sudo gtk-update-icon-cache -f /usr/share/icons/hicolor 2>&1); then
    echo_success "$icon_cache_output"
else
    echo_error "Error: $icon_cache_output"
fi

echo_success "Icon '$ICON_NAME' installed to '$ICON_TARGET_PATH' and icon cache updated."
