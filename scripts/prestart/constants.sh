#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# User and Group Configuration
# ------------------------------------------------------------------------------

readonly GROUP_NAME="deep-group"           # Group name for all deep work users
readonly USER_NAME="deep-worker"           # Default user for deep work
readonly USER_FULL_NAME="Deep Worker"      # Full name for the user

# ------------------------------------------------------------------------------
# Service Configuration
# ------------------------------------------------------------------------------

readonly LOCAL_FILE_SH="./systemd/focusd_script.sh"  # Path to the service script
readonly NAME_FILE_SH="focusd.sh"                    # Name of the installed script
readonly SERVICE_NAME="focusd.service"               # Systemd service name
readonly SERVICE_LOCATION="../services/"             # Location of the .service file
readonly LOG="focusd.log"                            # Log file name

# ------------------------------------------------------------------------------
# Icon Configuration
# ------------------------------------------------------------------------------

readonly ICON_SOURCE="../assets/focusd_icon.svg"                     # Local path to icon
readonly ICON_NAME="focusd.svg"                                      # Icon filename
readonly ICON_TARGET_DIR="/usr/share/icons/hicolor/scalable/apps"    # System icon target directory
readonly ICON_TARGET_PATH="${ICON_TARGET_DIR}/${ICON_NAME}"          # Full path to installed icon

# ------------------------------------------------------------------------------
# Hosts Configuration
# ------------------------------------------------------------------------------

readonly HOSTS_RESTRICTED_FILE="../hosts/hosts.restricted"
readonly HOSTS_DEFAULT_FILE="../hosts/hosts.default"
readonly HOSTS_BASE_FILE="../hosts/hosts.base"

readonly DOMAINS_DOPAMINE="../domains/domain-list-dopamine.txt"
readonly DOMAINS_ADULTS="../domains/domain-list-adults.txt"
readonly DOMAINS_SOCIAL_MEDIA="../domains/domain-list-social-media.txt"