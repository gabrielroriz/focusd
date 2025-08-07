#!/bin/bash

set -e

# ------------------------------------------------------------------------------
# Stop existing systemd service (if running)
# ------------------------------------------------------------------------------

sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true

# ------------------------------------------------------------------------------
# Copy systemd service file to system directory
# ------------------------------------------------------------------------------

sudo cp "$SERVICE_LOCATION/$SERVICE_NAME" "/etc/systemd/system/$SERVICE_NAME"

# ------------------------------------------------------------------------------
# Reload systemd, enable and start the service
# ------------------------------------------------------------------------------

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

# ------------------------------------------------------------------------------
# Show the service status
# ------------------------------------------------------------------------------

sudo systemctl status "$SERVICE_NAME"