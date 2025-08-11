#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Function: Extract filename from full path
# ------------------------------------------------------------------------------
get_filename() {
  local path="$1"
  local filename
  filename=$(basename "$path")
  echo "$filename"
}

# ------------------------------------------------------------------------------
# Function: Append comment line to a target file
# ------------------------------------------------------------------------------
add_comment(){
    local comment="$1"
    local file="$2"
    echo "# $comment" >> "$file"
}

# ------------------------------------------------------------------------------
# Function: Append N blank lines to a file
# ------------------------------------------------------------------------------
add_new_lines(){
    local n="$1"
    local file="$2"
    for (( i=0; i<=$n; i++ )) do
      printf "\n" >> "$file"
    done
}

# ------------------------------------------------------------------------------
# Function: Add a domain restriction line (0.0.0.0) to the target hosts file
# ------------------------------------------------------------------------------
add_restrict_domain(){
  local domain="$1"
  local file="$2"
  printf "0.0.0.0\t%s\n" "$domain" >> "$file"
}

# ------------------------------------------------------------------------------
# Function: Read valid domains from a file into global array `rows[]`
# Removes '*.domain.com' prefix and validates domain pattern
# ------------------------------------------------------------------------------
get_domains_from_file() {
  local file="$1"
  rows=()

  if [[ ! -f "$file" ]]; then
    echo "File not found: $file" >&2
    return 1
  fi

  while IFS= read -r row; do
    domain=$(echo "$row" | sed -E 's/^\*\.(.*)/\1/')
    if [[ "$domain" =~ ^[a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}$ ]]; then
      rows+=("$domain")
    fi
  done < "$file"
}

# ------------------------------------------------------------------------------
# Function: Append a section of blocked domains to the target hosts file
# Adds a comment, parses the domain file, and writes each entry
# ------------------------------------------------------------------------------
add_domains_to_host(){
  local host_file="$1"
  local domain_file="$2"
  local section_comment="$3"

  add_new_lines 1 "$host_file"
  add_comment "$section_comment" "$host_file"
  get_domains_from_file "$domain_file"

  for item in "${rows[@]}"; do
    add_restrict_domain "$item" "$host_file"
  done

  echo_success "$(get_filename $domain_file) added to $(get_filename $host_file): ${#rows[@]} domains."
}

# ------------------------------------------------------------------------------
# Function: Delete the specified file
# ------------------------------------------------------------------------------
remove_file(){
  local file="$1"
  sudo rm -rf "$file" \
  && echo_success "$(get_filename $file) removed."
}

# ------------------------------------------------------------------------------
# Function: Append the base hosts entries to a target file
# ------------------------------------------------------------------------------
add_hosts_base_or_backup_to_file(){
  local file="$1"
  if [[ -f "$HOSTS_BACKUP_FILE" ]]; then
    cat "$HOSTS_BACKUP_FILE" >> "$file" \
    && echo_success "Backup hosts added to $(get_filename $file)."
  else
    cat "$HOSTS_BASE_FILE" >> "$file" \
    && echo_success "Base hosts added to $(get_filename $file)."
  fi
}