#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Dynamic Hosts File Generator
# Generates hosts files based on unlock state and blocking categories
# ------------------------------------------------------------------------------

# Generate a hosts file with specified blocking level
# Arguments:
#   $1 - output file path
#   $2 - blocking level: "locked" (all blocks) or "unlocked" (only always-blocked)
generate_hosts_file() {
    local output_file="$1"
    local blocking_level="$2"
    
    # Start with a clean file
    > "$output_file"
    
    # Add header comment
    add_comment "Focusd dynamic hosts file - Level: $blocking_level" "$output_file"
    add_comment "Generated: $(date)" "$output_file"
    add_new_lines 1 "$output_file"
    
    # Always include base hosts
    if [ -f "$HOSTS_BASE_FILE" ]; then
        cat "$HOSTS_BASE_FILE" >> "$output_file"
        echo_success "Base hosts added to $(get_filename "$output_file")"
    elif [ -f "$HOSTS_BACKUP_FILE" ]; then
        cat "$HOSTS_BACKUP_FILE" >> "$output_file"
        echo_success "Backup hosts added to $(get_filename "$output_file")"
    fi
    
    # Always add always-blocked domains
    add_new_lines 1 "$output_file"
    add_comment "ALWAYS BLOCKED - Never unlockable" "$output_file"
    add_domains_from_directory "$output_file" "$DOMAINS_ALWAYS_BLOCKED_DIR" "Always blocked domains"
    
    # Add conditionally-blocked domains only if locked
    if [ "$blocking_level" = "locked" ]; then
        add_new_lines 1 "$output_file"
        add_comment "CONDITIONALLY BLOCKED - Temporarily unlockable" "$output_file"
        add_domains_from_directory "$output_file" "$DOMAINS_CONDITIONALLY_BLOCKED_DIR" "Conditionally blocked domains"
    fi
    
    echo_success "Generated hosts file: $(get_filename "$output_file") (level: $blocking_level)"
}

# Add all domains from all .txt files in a directory
add_domains_from_directory() {
    local host_file="$1"
    local domain_dir="$2"
    local section_comment="$3"
    
    if [ ! -d "$domain_dir" ]; then
        echo_warning "Directory not found: $domain_dir"
        return
    fi
    
    local total_domains=0
    
    # Process each .txt file in the directory
    for domain_file in "$domain_dir"/*.txt; do
        if [ -f "$domain_file" ]; then
            local category_name
            category_name=$(basename "$domain_file" .txt)
            
            add_new_lines 1 "$host_file"
            add_comment "Category: $category_name" "$host_file"
            
            get_domains_from_file "$domain_file"
            
            for item in "${rows[@]}"; do
                add_restrict_domain "$item" "$host_file"
            done
            
            total_domains=$((total_domains + ${#rows[@]}))
            echo_success "  Added $(basename "$domain_file"): ${#rows[@]} domains"
        fi
    done
    
    echo_success "Total domains from $(basename "$domain_dir"): $total_domains"
}

# Generate locked hosts file (all blocks active)
generate_locked_hosts() {
    local output_file="${1:-${SCRIPT_DIR}/../hosts/hosts.locked}"
    generate_hosts_file "$output_file" "locked"
}

# Generate unlocked hosts file (only always-blocked)
generate_unlocked_hosts() {
    local output_file="${1:-${SCRIPT_DIR}/../hosts/hosts.unlocked}"
    generate_hosts_file "$output_file" "unlocked"
}

# Generate both profiles
generate_all_hosts_profiles() {
    echo_header "Generating dynamic hosts profiles"
    
    generate_locked_hosts
    generate_unlocked_hosts
    
    echo_success "All hosts profiles generated successfully"
}
