#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Install executable script to /usr/local/bin and make it executable
# ------------------------------------------------------------------------------

sudo cp "$LOCAL_FILE_SH" "/usr/local/bin/$NAME_FILE_SH"
sudo chmod +x "/usr/local/bin/$NAME_FILE_SH"
