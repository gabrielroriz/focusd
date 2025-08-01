set -e

# ------------------------------------------------------------------------------
# Definition of utility functions
# ------------------------------------------------------------------------------

get_group_id(){
    local group_name="$1"
    grep "^${group_name}:" /etc/group | cut -d: -f3 # delimitador "-d:"; terceiro item "f3".
}

get_user_id(){
    local user_name="$1"
    grep "^${user_name}:" /etc/passwd | cut -d: -f3 # delimitador "-d:"; terceiro item "f3".
}

echo_green_mark(){
    local message="$1"
    echo "\e[32m✓\e[0m $message"
}

echo_red_x_error(){
    local message="$1"
    echo "\e[31m✗\e[0m $message" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Set default keyboard layout for new users via dconf and .xprofile
# ------------------------------------------------------------------------------

# Export current keyboard layout settings to a file inside /etc/skel
dconf dump /org/gnome/desktop/input-sources/ > /etc/skel/layout.dconf

# Create an .xprofile script that will apply the layout when a new user logs in
cat > "/etc/skel/.xprofile" <<'EOF'
#!/bin/bash

if [ -f "$HOME/layout.dconf" ]; then
  dconf load /org/gnome/desktop/input-sources/ < "$HOME/layout.dconf"
  rm "$HOME/layout.dconf"
fi
EOF

# Make the .xprofile script executable
sudo chmod +x "/etc/skel/.xprofile"

# ------------------------------------------------------------------------------
# Global variables to setup deep work environment
# ------------------------------------------------------------------------------

# Group name for all deep work users.
GROUP_NAME="deep-group"

# Default user for deep work
USER_NAME="deep-worker"

# ------------------------------------------------------------------------------
# Ensure required group exists
# ------------------------------------------------------------------------------

# Try to retrieve the group ID for the given group name.
GROUP_ID=$(get_group_id $GROUP_NAME)

# Check if the group already exists
if [ -n "$GROUP_ID" ]; then
    echo_green_mark "Group '$GROUP_NAME' already exists with GID $GROUP_ID."
else
    # If the group does not exist, create it
    echo "Group '$GROUP_NAME' not found. Creating..."
    sudo groupadd $GROUP_NAME

    # Re-fetch the group ID after creation
    GROUP_ID=$(get_group_id $GROUP_NAME)

    # Confirm successful creation
    echo_green_mark "Group '$GROUP_NAME' created successfully with GID $GROUP_ID."
fi

# ------------------------------------------------------------------------------
# Ensure required user exists
# ------------------------------------------------------------------------------

USER_ID=$(get_user_id $USER_NAME)

# Check if the user already exists
if [ -n "$USER_ID" ]; then
    echo_green_mark "User '$USER_NAME' already exists with UID $USER_ID."
    if groups $USER_NAME | grep -q $GROUP_NAME; then
        sudo usermod -aG $GROUP_NAME $USER_NAME
        echo_green_mark "User '$USER_NAME'($USER_ID) appended to group '$GROUP_NAME'($GROUP_ID)."
    else
        echo_green_mark "User '$USER_NAME'($USER_ID) already is in group '$GROUP_NAME'($GROUP_ID)."
    fi
else
    # If the user does not exist, create it
    echo "User '$USER_NAME' not found. Creating..."
    sudo useradd -m -G "$GROUP_NAME,sudo" -s /bin/bash $USER_NAME # -m = creates home folder; -G = attach user to group.
    sudo passwd "$USER_NAME"

    # Re-fetch the user ID after creation
    USER_ID=$(get_group_id $USER_NAME)

    # Confirm successful creation
    echo_green_mark "User '$USER_NAME' (with UID $USER_ID) created successfully and appended to group '$GROUP_NAME'($GROUP_ID)"
fi

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

FILE_SH="focusd.sh"
SERVICE="focusd.service"
LOG="focusd.log"

# ------------------------------------------------------------------------------
# Install executable script to /usr/local/bin and make it executable
# ------------------------------------------------------------------------------

sudo cp "$FILE_SH" "/usr/local/bin/$FILE_SH"
sudo chmod +x "/usr/local/bin/$FILE_SH"

# ------------------------------------------------------------------------------
# Recreate the log file
# ------------------------------------------------------------------------------

sudo rm -rf "/var/log/$LOG"
sudo touch "/var/log/$LOG"

# ------------------------------------------------------------------------------
# Stop existing systemd service (if running)
# ------------------------------------------------------------------------------

sudo systemctl stop "$SERVICE" 2>/dev/null || true

# ------------------------------------------------------------------------------
# Copy systemd service file to system directory
# ------------------------------------------------------------------------------

sudo cp "$SERVICE" "/etc/systemd/system/$SERVICE"

# ------------------------------------------------------------------------------
# Reload systemd, enable and start the service
# ------------------------------------------------------------------------------

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE"
sudo systemctl start "$SERVICE"

# ------------------------------------------------------------------------------
# Show the service status
# ------------------------------------------------------------------------------

sudo systemctl status "$SERVICE"
