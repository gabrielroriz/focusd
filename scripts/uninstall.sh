#!/bin/bash
set -e

# -----------------------------------------------------------------------
# Focusd Uninstall Script
# -----------------------------------------------------------------------
# This script removes all focusd components from the system:
# - systemd service
# - CLI tool
# - Configuration files
# - State files
# - User and group
# - Restores original /etc/hosts
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
# Base Directory (directory of this script)
# -----------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -----------------------------------------------------------------------
# Prestart Utilities
# -----------------------------------------------------------------------
source "${SCRIPT_DIR}/prestart/constants.sh"
source "${SCRIPT_DIR}/prestart/echo_utils.sh"

# -----------------------------------------------------------------------
# Systemd Service Removal
# -----------------------------------------------------------------------
echo_header "Removing Systemd Service"

if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo_info "Stopping $SERVICE_NAME..."
    sudo systemctl stop "$SERVICE_NAME"
    echo_success "Service stopped."
fi

if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo_info "Disabling $SERVICE_NAME..."
    sudo systemctl disable "$SERVICE_NAME"
    echo_success "Service disabled."
fi

if [[ -f "/etc/systemd/system/$SERVICE_NAME" ]]; then
    echo_info "Removing service file..."
    sudo rm -f "/etc/systemd/system/$SERVICE_NAME"
    echo_success "Service file removed."
fi

sudo systemctl daemon-reload
echo_success "Systemd service removed successfully."

# -----------------------------------------------------------------------
# CLI Tool Removal
# -----------------------------------------------------------------------
echo_header "Removing CLI Tool"

if [[ -f "$FOCUSD_CLI_BIN" ]]; then
    echo_info "Removing focusd CLI from $FOCUSD_CLI_BIN..."
    sudo rm -f "$FOCUSD_CLI_BIN"
    echo_success "CLI tool removed."
else
    echo_info "CLI tool not found at $FOCUSD_CLI_BIN (skipping)."
fi

# -----------------------------------------------------------------------
# Library Removal
# -----------------------------------------------------------------------
echo_header "Removing Libraries"

if [[ -d "/usr/local/lib/focusd" ]]; then
    echo_info "Removing state manager library..."
    sudo rm -rf "/usr/local/lib/focusd"
    echo_success "Library removed."
else
    echo_info "Library directory not found (skipping)."
fi

# -----------------------------------------------------------------------
# Executable Script Removal
# -----------------------------------------------------------------------
echo_header "Removing Executable Script"

if [[ -f "/usr/local/bin/$NAME_FILE_SH" ]]; then
    echo_info "Removing $NAME_FILE_SH from /usr/local/bin..."
    sudo rm -f "/usr/local/bin/$NAME_FILE_SH"
    echo_success "Executable script removed."
else
    echo_info "Executable script not found (skipping)."
fi

# -----------------------------------------------------------------------
# Icon Removal
# -----------------------------------------------------------------------
echo_header "Removing Icon"

if [[ -f "$ICON_TARGET_PATH" ]]; then
    echo_info "Removing icon from $ICON_TARGET_PATH..."
    sudo rm -f "$ICON_TARGET_PATH"
    sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
    echo_success "Icon removed."
else
    echo_info "Icon not found (skipping)."
fi

# -----------------------------------------------------------------------
# Configuration Removal
# -----------------------------------------------------------------------
echo_header "Removing Configuration"

if [[ -d "$FOCUSD_CONFIG_DIR" ]]; then
    echo_info "Removing configuration directory $FOCUSD_CONFIG_DIR..."
    sudo rm -rf "$FOCUSD_CONFIG_DIR"
    echo_success "Configuration removed."
else
    echo_info "Configuration directory not found (skipping)."
fi

# -----------------------------------------------------------------------
# State Removal
# -----------------------------------------------------------------------
echo_header "Removing State Files"

if [[ -d "$FOCUSD_STATE_DIR" ]]; then
    echo_info "Removing state directory $FOCUSD_STATE_DIR..."
    sudo rm -rf "$FOCUSD_STATE_DIR"
    echo_success "State files removed."
else
    echo_info "State directory not found (skipping)."
fi

# -----------------------------------------------------------------------
# Hosts File Restoration
# -----------------------------------------------------------------------
echo_header "Restoring Hosts File"

if [[ -f "$HOSTS_BACKUP_FILE" ]]; then
    echo_info "Restoring original /etc/hosts from backup..."
    sudo cp "$HOSTS_BACKUP_FILE" /etc/hosts
    echo_success "/etc/hosts restored from backup."
    
    echo_info "Removing backup file..."
    sudo rm -f "$HOSTS_BACKUP_FILE"
    echo_success "Backup file removed."
else
    echo_warning "No hosts backup found at $HOSTS_BACKUP_FILE (skipping restoration)."
fi

# -----------------------------------------------------------------------
# Log File Removal
# -----------------------------------------------------------------------
echo_header "Removing Log Files"

if [[ -f "/var/log/$LOG" ]]; then
    echo_info "Removing log file /var/log/$LOG..."
    sudo rm -f "/var/log/$LOG"
    echo_success "Log file removed."
else
    echo_info "Log file not found (skipping)."
fi

# -----------------------------------------------------------------------
# User and Group Removal
# -----------------------------------------------------------------------
echo_header "Removing User and Group"

source "${SCRIPT_DIR}/user/remove_user_and_group.sh"

# -----------------------------------------------------------------------
# XProfile Configuration Removal
# -----------------------------------------------------------------------
echo_header "Removing XProfile Configuration"

# Remove focusd group assignment from .xprofile for all users
for user_home in /home/*; do
    if [[ -d "$user_home" ]]; then
        username=$(basename "$user_home")
        xprofile_file="$user_home/.xprofile"
        
        if [[ -f "$xprofile_file" ]]; then
            if grep -q "newgrp $GROUP_NAME" "$xprofile_file" 2>/dev/null; then
                echo_info "Removing focusd configuration from $xprofile_file..."
                sudo sed -i "/newgrp $GROUP_NAME/d" "$xprofile_file"
                echo_success "Configuration removed from $username's .xprofile."
            fi
        fi
    fi
done

# -----------------------------------------------------------------------
# Completion Message
# -----------------------------------------------------------------------
echo ""
echo_success "╔════════════════════════════════════════════════════════════╗"
echo_success "║                                                            ║"
echo_success "║     Focusd has been completely uninstalled!                ║"
echo_success "║                                                            ║"
echo_success "║     All components have been removed from your system.     ║"
echo_success "║     Please log out and log back in for all changes to      ║"
echo_success "║     take effect.                                           ║"
echo_success "║                                                            ║"
echo_success "╚════════════════════════════════════════════════════════════╝"
echo ""
