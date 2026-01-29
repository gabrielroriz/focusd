#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# State Management Functions for Unlock/Lock Mechanism
# ------------------------------------------------------------------------------

# State Manager is a library -- set of functions -- that is used to manage 
# the unlock/lock state of the Focusd application (for CLI and daemon service).

# Initialize state file with locked state
init_unlock_state() {
    if [ ! -d "$FOCUSD_STATE_DIR" ]; then
        mkdir -p "$FOCUSD_STATE_DIR"
        chmod 755 "$FOCUSD_STATE_DIR"
    fi

    if [ ! -f "$FOCUSD_STATE_FILE" ]; then
        cat > "$FOCUSD_STATE_FILE" << EOF
IS_UNLOCKED=false
UNLOCK_TIMESTAMP=0
UNLOCK_DURATION=300
UNLOCKED_CATEGORIES=
EOF
        chmod 644 "$FOCUSD_STATE_FILE"
        echo_success "Unlock state initialized at $FOCUSD_STATE_FILE"
    else
        echo_success "Found existing state file at $FOCUSD_STATE_FILE"
    fi
}

# Read a value from the state file
get_state_value() {
    local key="$1"
    local default_value="${2:-}"
    
    if [ ! -f "$FOCUSD_STATE_FILE" ]; then
        echo "$default_value"
        return
    fi
    
    local value
    value=$(grep "^${key}=" "$FOCUSD_STATE_FILE" | cut -d'=' -f2- || echo "$default_value")
    echo "$value"
}

# Write a value to the state file
set_state_value() {
    local key="$1"
    local value="$2"
    
    if [ ! -f "$FOCUSD_STATE_FILE" ]; then
        init_unlock_state
    fi
    
    if grep -q "^${key}=" "$FOCUSD_STATE_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$FOCUSD_STATE_FILE"
    else
        echo "${key}=${value}" >> "$FOCUSD_STATE_FILE"
    fi
}

# Check if currently unlocked
is_unlocked() {
    local unlocked
    unlocked=$(get_state_value "IS_UNLOCKED" "false")
    [ "$unlocked" = "true" ]
}

# Get unlock expiry timestamp (unlock_timestamp + duration)
get_unlock_expiry() {
    local timestamp
    local duration
    timestamp=$(get_state_value "UNLOCK_TIMESTAMP" "0")
    duration=$(get_state_value "UNLOCK_DURATION" "300")
    echo $((timestamp + duration))
}

# Get time remaining in seconds
get_time_remaining() {
    local expiry
    local now
    expiry=$(get_unlock_expiry)
    now=$(date +%s)
    local remaining=$((expiry - now))
    [ $remaining -lt 0 ] && remaining=0
    echo $remaining
}

# Set unlocked state
set_unlocked() {
    local duration="${1:-300}"
    local categories="${2:-all}"
    local now
    now=$(date +%s)
    
    set_state_value "IS_UNLOCKED" "true"
    set_state_value "UNLOCK_TIMESTAMP" "$now"
    set_state_value "UNLOCK_DURATION" "$duration"
    set_state_value "UNLOCKED_CATEGORIES" "$categories"
}

# Set locked state
set_locked() {
    set_state_value "IS_UNLOCKED" "false"
    set_state_value "UNLOCK_TIMESTAMP" "0"
    set_state_value "UNLOCKED_CATEGORIES" ""
}

# Check if unlock has expired
check_unlock_expired() {
    if ! is_unlocked; then
        return 1  # Not unlocked, so can't be expired
    fi
    
    local expiry
    local now
    expiry=$(get_unlock_expiry)
    now=$(date +%s)
    
    [ $now -ge $expiry ]
}

# Get formatted time remaining (e.g., "3m 45s")
format_time_remaining() {
    local seconds
    seconds=$(get_time_remaining)
    
    if [ $seconds -eq 0 ]; then
        echo "0s"
        return
    fi
    
    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))
    
    if [ $minutes -gt 0 ]; then
        echo "${minutes}m ${secs}s"
    else
        echo "${secs}s"
    fi
}
