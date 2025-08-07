#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Ensure required group exists
# ------------------------------------------------------------------------------

# Try to retrieve the group ID for the given group name.
GROUP_ID=$(get_group_id $GROUP_NAME)

# Check if the group already exists
if [ -n "$GROUP_ID" ]; then
    echo_success "Group '$GROUP_NAME' already exists with GID $GROUP_ID."
else
    # If the group does not exist, create it
    echo "Group '$GROUP_NAME' not found. Creating..."
    sudo groupadd $GROUP_NAME

    # Re-fetch the group ID after creation
    GROUP_ID=$(get_group_id $GROUP_NAME)

    # Confirm successful creation
    echo_success "Group '$GROUP_NAME' created successfully with GID $GROUP_ID."
fi