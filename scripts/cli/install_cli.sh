#!/bin/bash

set -e

# Check if the source script exists
if [[ ! -f "$FOCUSD_CLI_SCRIPT" ]]; then
    echo_error "Error: Source script not found at $FOCUSD_CLI_SCRIPT"
    exit 1
fi

# Check if we have write permissions to /usr/local/bin
if [[ ! -w "/usr/local/bin" ]]; then
    echo_error "Error: No write permission to /usr/local/bin. Try running with sudo."
    exit 1
fi

# Install the CLI script
echo_info "Installing focusd CLI to $FOCUSD_CLI_BIN..."
cp "$FOCUSD_CLI_SCRIPT" "$FOCUSD_CLI_BIN"

# Make it executable
chmod +x "$FOCUSD_CLI_BIN"

echo_success "Installation completed successfully! You can now use 'focusd' command from anywhere."