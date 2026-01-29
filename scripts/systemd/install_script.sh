#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Install executable script to /usr/local/bin and make it executable
# ------------------------------------------------------------------------------

sudo cp "$LOCAL_FILE_SH" "/usr/local/bin/$NAME_FILE_SH"
sudo chmod +x "/usr/local/bin/$NAME_FILE_SH"

# ------------------------------------------------------------------------------
# Install state manager library
# ------------------------------------------------------------------------------

sudo mkdir -p "/usr/local/lib/focusd"
sudo cp "${SCRIPT_DIR}/state/state_manager.sh" "/usr/local/lib/focusd/state_manager.sh"
sudo chmod 644 "/usr/local/lib/focusd/state_manager.sh"
echo_success "State manager library installed to /usr/local/lib/focusd/"
