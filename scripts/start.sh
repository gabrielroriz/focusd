#!/bin/bash
set -e

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
# User Setup
# -----------------------------------------------------------------------
source "${SCRIPT_DIR}/user/prestart.sh"
source "${SCRIPT_DIR}/user/config_xprofile.sh"
source "${SCRIPT_DIR}/user/create_group.sh"
source "${SCRIPT_DIR}/user/create_user.sh"

# -----------------------------------------------------------------------
# Config Setup
# -----------------------------------------------------------------------
source "${SCRIPT_DIR}/config/create_config.sh"

# -----------------------------------------------------------------------
# Hosts Setup
# -----------------------------------------------------------------------
source "${SCRIPT_DIR}/hosts/prestart.sh"
source "${SCRIPT_DIR}/hosts/create_hosts_restricted.sh"
source "${SCRIPT_DIR}/hosts/create_hosts_default.sh"
source "${SCRIPT_DIR}/hosts/create_hosts_no_social.sh"
source "${SCRIPT_DIR}/hosts/update_etc_hosts.sh"

# -----------------------------------------------------------------------
# Systemd Setup
# -----------------------------------------------------------------------
source "${SCRIPT_DIR}/systemd/install_icon.sh"
source "${SCRIPT_DIR}/systemd/install_script.sh"
source "${SCRIPT_DIR}/systemd/create_log.sh"
source "${SCRIPT_DIR}/systemd/run_service.sh"