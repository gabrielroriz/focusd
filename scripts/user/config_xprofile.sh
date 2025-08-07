#!/bin/bash

set -e

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
