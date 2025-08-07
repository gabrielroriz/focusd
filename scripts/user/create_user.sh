#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Ensure required user exists
# ------------------------------------------------------------------------------

USER_ID=$(get_user_id $USER_NAME)

# Check if the user already exists
if [ -n "$USER_ID" ]; then
    echo_success "User '$USER_NAME' already exists with UID $USER_ID."
    if groups $USER_NAME | grep -q $GROUP_NAME; then
        sudo usermod -aG $GROUP_NAME $USER_NAME
        echo_success "User '$USER_NAME'($USER_ID) appended to group '$GROUP_NAME'($GROUP_ID)."
    else
        echo_success "User '$USER_NAME'($USER_ID) already is in group '$GROUP_NAME'($GROUP_ID)."
    fi
else
    # If the user does not exist, create it
    echo "User '$USER_NAME' not found. Creating..."
    sudo useradd -m -G "$GROUP_NAME,sudo" -s /bin/bash $USER_NAME # -m = creates home folder; -G = attach user to group.
    sudo usermod -c "$USER_FULL_NAME" "$USER_NAME"
    sudo passwd "$USER_NAME"

    # Re-fetch the user ID after creation
    USER_ID=$(get_group_id $USER_NAME)

    # Confirm successful creation
    echo_success "User '$USER_NAME' (with UID $USER_ID) created successfully and appended to group '$GROUP_NAME'($GROUP_ID)"
fi