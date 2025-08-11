![Status](https://img.shields.io/badge/status-active-success)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)
![Last Commit](https://img.shields.io/github/last-commit/gabrielroriz/focusd)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=flat-square&logo=gnu-bash&logoColor=white)
![systemd](https://img.shields.io/badge/systemd_service-3A3A3A?style=flat-square&logo=systemd&logoColor=white)
![D-Bus](https://img.shields.io/badge/D--Bus-2C2C2C?style=flat-square)

<p align="center">
  <img src="assets/focusd_icon.svg" alt="focusd banner" width="120" height="120">
</p>

<h1 align="center">
    <code>focusd</code>
</h1>

<p align="center">
  <quote>Linux productivity tool for blocking distractions and boosting focus.
</p>

# Welcome

`focusd` is a Linux productivity tool that helps users maintain focus by blocking distracting websites and services. It works by managing the `/etc/hosts` file based on user group membership.

The system creates different host file profiles (default, no social media, restricted) and automatically applies them based on which user group is active. It includes predefined domain lists for social media, dopamine-inducing sites, and adult content blocking.

## Table of contents

- [Welcome](#welcome)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installing \& deployment](#installing--deployment)
    - [How it works](#how-it-works)
  - [Roadmap](#roadmap)
    - [Completed Features](#completed-features)
  - [Done](#done)
  - [In Progress](#in-progress)
  - [Planned](#planned)
    - [Future Considerations](#future-considerations)

## Getting started

### Prerequisites

- **Linux operating system** with systemd support
- **Bash shell** (version 4.0 or higher)
- **systemd** for service management
- **D-Bus** for inter-process communication
- **Root/sudo privileges** for system file modifications
- **X11 or Wayland** desktop environment (for tray app)

### Installing & deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/gabrielroriz/focusd.git
   cd focusd
   ```

2. Run the installation script:
   ```bash
   sudo ./scripts/start.sh
   ```

This script will:
- Create a dedicated user (`deep-worker`) and group (`deep-group`)
- Set up configuration files in `/etc/focusd/` (`/etc/focusd/focusd.conf`)
- Create different host file profiles (located in `/etc/focusd/hosts_profiles/`)
- Install and enable the systemd service ( `focusd.service`)

### How it works

1. **User Groups**: The system creates a special user (`deep-worker`) and group (`deep-group`)
   
2. **Host File Management**: Different host file profiles block various categories of websites:
   - `hosts.default`: Basic system hosts
   - `hosts.no_social`: Blocks social media sites
   - `hosts.restricted`: Comprehensive blocking including dopamine-inducing content
  
3. **Dynamic Switching**: The systemd service monitors which user is active and applies the appropriate host file

## Roadmap

### Completed Features

## Done
- [x] Basic installation and setup scripts
- [x] Systemd service integration  
- [x] Multiple host file profiles (default, no-social, restricted)
- [x] User and group management system 
- [x] Domain list management for different categories  

## In Progress

## Planned
- [ ] CLI Management Tool  
- [ ] Tray App  
- [ ] Statistics and Analytics
- [ ] Configuration Web UI  
- [ ] Time-based Scheduling  
- [ ] Custom Domain Lists
- [ ] Whitelist Support 
- [ ] Multi-user Support
- [ ] Browser Extensions

### Future Considerations
- Support for additional Linux distributions
- Integration with popular productivity frameworks (Pomodoro, time blocking)
- Machine learning-based distraction detection
- Team/organization deployment tools

